use andromeda_api::{Auth, ChildSession, EnvId, Store, StoreError, Tokens, WalletAuthStore};
use async_trait::async_trait;
use flutter_rust_bridge::frb;
use std::sync::{
    atomic::{AtomicBool, Ordering},
    Arc,
};
use tokio::sync::Mutex;
use tracing::info;

pub type DartCallback = dyn Fn(ChildSession) -> DartFnFuture<String> + Send + Sync;

use crate::proton_wallet::common::callbacks::DartFnFuture;
use crate::BridgeError;

lazy_static::lazy_static! {
    static ref GLOBAL_SESSION_DART_CALLBACK: Mutex<Option<Arc<DartCallback>>> = Mutex::new(None);
}

static API_CLIENT_INITIALIZING: AtomicBool = AtomicBool::new(false);

pub(crate) fn set_api_client_initializing(initializing: bool) {
    API_CLIENT_INITIALIZING.store(initializing, Ordering::SeqCst);
}

fn is_api_client_initializing() -> bool {
    API_CLIENT_INITIALIZING.load(Ordering::SeqCst)
}

fn auth_session_changed(previous: &Auth, updated: &Auth) -> bool {
    if matches!(updated, Auth::None) {
        return false;
    }
    previous.uid() != updated.uid()
        || previous.acc_tok() != updated.acc_tok()
        || previous.ref_tok() != updated.ref_tok()
        || previous.scopes() != updated.scopes()
}

async fn notify_auth_session_changed(previous: &Auth, updated: &Auth) {
    if matches!(updated, Auth::None) {
        info!("notify skipped: updated auth is None");
        return;
    }
    if !auth_session_changed(previous, updated) {
        info!("notify skipped: session tokens unchanged");
        return;
    }
    if is_api_client_initializing() {
        info!("notify skipped: api client initializing");
        return;
    }
    info!("notify: session changed, scheduling dart callback");
    refresh_auth_credential(updated.clone()).await;
}

/// Wraps [`WalletAuthStore`] to notify Dart when muon refreshes auth tokens.
struct CallbackWalletAuthStore {
    inner: WalletAuthStore,
}

impl CallbackWalletAuthStore {
    fn new(inner: WalletAuthStore) -> Self {
        Self { inner }
    }
}

#[async_trait]
impl Store<()> for CallbackWalletAuthStore {
    fn env(&self) -> EnvId {
        self.inner.env()
    }

    async fn get_auth(&self, key: &()) -> Result<Auth, StoreError> {
        self.inner.get_auth(key).await
    }

    async fn set_auth(&mut self, key: &(), auth: Auth) -> Result<(), StoreError> {
        let previous = self.inner.get_auth(key).await.unwrap_or(Auth::None);
        self.inner.set_auth(key, auth.clone()).await?;
        notify_auth_session_changed(&previous, &auth).await;
        Ok(())
    }

    async fn remove_auth(&mut self, key: &()) -> Result<Option<Auth>, StoreError> {
        self.inner.remove_auth(key).await
    }

    async fn get_all_auth(&self) -> Result<std::collections::HashMap<(), Auth>, StoreError> {
        self.inner.get_all_auth().await
    }

    async fn set_all_auth(
        &mut self,
        auth: std::collections::HashMap<(), Auth>,
    ) -> Result<(), StoreError> {
        let previous = self.inner.get_auth(&()).await.unwrap_or(Auth::None);
        self.inner.set_all_auth(auth.clone()).await?;
        if let Some(updated) = auth.get(&()) {
            notify_auth_session_changed(&previous, updated).await;
        }
        Ok(())
    }

    async fn remove_all_auth(&mut self) -> Result<(), StoreError> {
        self.inner.remove_all_auth().await
    }
}

#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct ProtonWalletAuthStore {
    pub(crate) inner: WalletAuthStore,
}

impl ProtonWalletAuthStore {
    pub(crate) fn callback_store(&self) -> Box<dyn Store<()>> {
        Box::new(CallbackWalletAuthStore::new(self.inner.clone()))
    }

    #[frb(sync)]
    pub fn new(env: &str) -> Result<Self, BridgeError> {
        let auth = Arc::new(std::sync::Mutex::new(Auth::None));
        ProtonWalletAuthStore::from_auth(env, auth)
    }

    #[frb(ignore)]
    pub(crate) fn from_auth(
        env: &str,
        auth: Arc<std::sync::Mutex<Auth>>,
    ) -> Result<Self, BridgeError> {
        info!("from_auth start");
        let store = WalletAuthStore::from_env_str(env.to_string(), auth);
        Ok(Self { inner: store })
    }

    #[frb(sync)]
    pub fn from_session(
        env: &str,
        user_id: String,
        uid: String,
        access: String,
        refresh: String,
        scopes: Vec<String>,
    ) -> Result<Self, BridgeError> {
        let auth = Auth::internal(user_id, uid, Tokens::access(access, refresh, scopes));
        info!("from_session start");
        ProtonWalletAuthStore::from_auth(env, Arc::new(std::sync::Mutex::new(auth)))
    }

    #[frb(sync)]
    pub fn set_auth_sync(
        &mut self,
        user_id: String,
        uid: String,
        access: String,
        refresh: String,
        scopes: Vec<String>,
    ) -> Result<(), BridgeError> {
        info!("set_auth_sync start");
        let auth = Auth::internal(user_id, uid, Tokens::access(access, refresh, scopes));
        let mut old_auth = self.inner.auth.lock()?;
        *old_auth = auth;
        Ok(())
    }

    pub async fn set_auth_dart_callback(
        &mut self,
        callback: impl Fn(ChildSession) -> DartFnFuture<String> + Send + Sync + 'static,
    ) -> Result<(), BridgeError> {
        let mut cb = GLOBAL_SESSION_DART_CALLBACK.lock().await;
        *cb = Some(Arc::new(callback));
        info!("set_auth_dart_callback ok");
        Ok(())
    }

    pub async fn clear_auth_dart_callback(&self) -> Result<(), BridgeError> {
        let mut cb = GLOBAL_SESSION_DART_CALLBACK.lock().await;
        *cb = None;
        info!("clear_auth_dart_callback ok");
        Ok(())
    }

    pub async fn logout(&mut self) -> Result<(), BridgeError> {
        info!("logout");
        let mut cb = GLOBAL_SESSION_DART_CALLBACK.lock().await;
        *cb = None;
        let mut auth = self.inner.auth.lock()?;
        *auth = Auth::None;
        Ok(())
    }
}

async fn refresh_auth_credential(auth: Auth) {
    info!("refresh_auth_credential start");
    let callback_option = {
        let guard = GLOBAL_SESSION_DART_CALLBACK.lock().await;
        guard.as_ref().cloned()
    };

    flutter_rust_bridge::spawn(async move {
        if let Some(callback) = callback_option {
            info!("refresh_auth_credential found callback and calling it");
            let session = ChildSession {
                scopes: auth.scopes().map(|s| s.to_vec()).unwrap_or_default(),
                session_id: auth.uid().unwrap_or_default().to_string(),
                access_token: auth.acc_tok().unwrap_or_default().to_string(),
                refresh_token: auth.ref_tok().unwrap_or_default().to_string(),
            };
            let msg = callback(session).await;
            info!("refresh_auth_credential messageFromDart: {msg}");
        } else {
            info!("refresh_auth_credential skipped: no dart callback registered");
        }
    });
    info!("refresh_auth_credential end (spawn scheduled)");
}

/// test supports
#[cfg(test)]
pub(crate) mod test_exports {
    use std::sync::Arc;

    use super::*;

    pub fn auth_session_changed(previous: &Auth, updated: &Auth) -> bool {
        super::auth_session_changed(previous, updated)
    }

    pub fn set_api_client_initializing(initializing: bool) {
        super::set_api_client_initializing(initializing);
    }

    pub fn global_session_dart_callback() -> &'static Mutex<Option<Arc<DartCallback>>> {
        &GLOBAL_SESSION_DART_CALLBACK
    }

    pub fn new_callback_store(inner: WalletAuthStore) -> Box<dyn Store<()>> {
        Box::new(CallbackWalletAuthStore::new(inner))
    }
}

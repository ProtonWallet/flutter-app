use andromeda_api::{Auth, ChildSession, Tokens, WalletAuthStore};
use flutter_rust_bridge::frb;
use std::sync::Arc;
use tokio::sync::Mutex;
use tracing::info;

pub type DartCallback = dyn Fn(ChildSession) -> DartFnFuture<String> + Send + Sync;

use crate::proton_wallet::common::callbacks::DartFnFuture;
use crate::BridgeError;

lazy_static::lazy_static! {
    static ref GLOBAL_SESSION_DART_CALLBACK: Mutex<Option<Arc<DartCallback>>> = Mutex::new(None);
}

#[derive(Debug, Clone)]
#[frb(opaque)]
pub struct ProtonWalletAuthStore {
    pub(crate) inner: WalletAuthStore,
}

impl ProtonWalletAuthStore {
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
        let mut store = WalletAuthStore::from_env_str(env.to_string(), auth);
        store.set_auth_listener(Arc::new(refresh_auth_credential));
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

fn refresh_auth_credential(auth: Auth) {
    info!("refresh_auth_credential start");
    let Ok(handle) = tokio::runtime::Handle::try_current() else {
        info!("refresh_auth_credential skipped: no tokio runtime");
        return;
    };

    handle.spawn(async move {
        tokio::task::yield_now().await;
        info!("refresh_auth_credential run deferred callback");
        let cb = GLOBAL_SESSION_DART_CALLBACK.lock().await;
        if let Some(callback) = cb.as_ref() {
            info!("refresh_auth_credential found callback and calling it");
            let session = ChildSession {
                scopes: auth
                    .scopes()
                    .map(|s| s.iter().cloned().collect())
                    .unwrap_or_default(),
                session_id: auth.uid().unwrap_or_default().to_string(),
                access_token: auth.acc_tok().unwrap_or_default().to_string(),
                refresh_token: auth.ref_tok().unwrap_or_default().to_string(),
            };
            let msg = callback(session).await;
            info!("refresh_auth_credential messageFromDart: {}", msg);
        }
    });
    info!("refresh_auth_credential end");
}

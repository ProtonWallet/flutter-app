use andromeda_api::{Auth, ChildSession, EnvId, Store, StoreFailure, Tokens, WalletAuthStore};
use flutter_rust_bridge::frb;
use log::info;
use std::sync::Arc;
use tokio::sync::Mutex;
pub type DartCallback = dyn Fn(ChildSession) -> DartFnFuture<String> + Send + Sync;

use crate::proton_wallet::common::callbacks::DartFnFuture;
use crate::BridgeError;

lazy_static::lazy_static! {
    static ref GLOBAL_SESSION_DART_CALLBACK: Mutex<Option<Arc<DartCallback>>> = Mutex::new(None);
}

#[derive(Debug, Clone)]
#[frb(opaque)]
// Define a new struct that wraps WalletAuthStore
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
        let store = WalletAuthStore::from_env_str(env.to_string(), auth);
        Ok(Self { inner: store })
    }

    #[frb(sync)]
    pub fn from_session(
        env: &str,
        uid: String,
        access: String,
        refresh: String,
        scopes: Vec<String>,
    ) -> Result<Self, BridgeError> {
        let auth = Auth::internal(uid, Tokens::access(access, refresh, scopes));
        info!("from_session start");
        ProtonWalletAuthStore::from_auth(env, Arc::new(std::sync::Mutex::new(auth)))
    }

    #[frb(sync)]
    pub fn set_auth_sync(
        &mut self,
        uid: String,
        access: String,
        refresh: String,
        scopes: Vec<String>,
    ) -> Result<(), BridgeError> {
        info!("set_auth_sync start");
        let auth = Auth::internal(uid, Tokens::access(access, refresh, scopes));
        let _ = self.inner.set_auth(auth);
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
        let mut old_auth = self.inner.auth.lock()?;
        *old_auth = Auth::None;

        Ok(())
    }

    fn refresh_auth_credential(&self, auth: Auth) {
        info!("refresh_auth_credential- start:");
        // let rt = self.rt.clone();
        tokio::spawn(async move {
            // Assuming `self` is accessible here
            // rt.block_on(async move {
            info!("refresh_auth_credential run block on");
            let cb = GLOBAL_SESSION_DART_CALLBACK.lock().await;
            if let Some(callback) = cb.as_ref() {
                info!("refresh_auth_credential found callback and calling it");
                let session = ChildSession {
                    scopes: auth.scopes().unwrap_or_default().to_vec(),
                    session_id: auth.uid().unwrap_or_default().to_string(),
                    access_token: auth.acc_tok().unwrap_or_default().to_string(),
                    refresh_token: auth.ref_tok().unwrap_or_default().to_string(),
                };
                let msg = callback(session).await;
                info!("refresh_auth_credential messageFromDart: {}", msg);
            }
            // });
        });
        info!("refresh_auth_credential- end");
    }
}

impl Store for ProtonWalletAuthStore {
    fn env(&self) -> EnvId {
        info!("ProtonWalletAuthStore env");
        self.inner.env()
    }

    fn get_auth(&self) -> Auth {
        info!("ProtonWalletAuthStore get_auth");
        self.inner.get_auth()
    }

    fn set_auth(&mut self, auth: Auth) -> std::result::Result<Auth, StoreFailure> {
        info!("Custom set_auth: {:?}", auth.clone());
        let result = self.inner.set_auth(auth.clone())?;
        self.refresh_auth_credential(auth.clone());
        Ok(result)
    }
}

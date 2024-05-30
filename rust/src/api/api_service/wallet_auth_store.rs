use std::{future::Future, pin::Pin, sync::Arc};

use andromeda_api::{
    Auth, ChildSession, EnvId, SimpleAuthStore, Store, StoreReadErr, StoreWriteErr, Tokens,
};
use flutter_rust_bridge::frb;
use log::info;

use crate::errors::ApiError;
use tokio::sync::Mutex;
pub type DartFnFuture<T> = Pin<Box<dyn Future<Output = T> + Send + 'static>>;
pub type DartCallback = dyn Fn(ChildSession) -> DartFnFuture<String> + Send + Sync;

lazy_static::lazy_static! {
    static ref GLOBAL_SESSION_DART_CALLBACK: Mutex<Option<Arc<DartCallback>>> = Mutex::new(None);
}

#[derive(Debug, Clone)]
#[frb(opaque)]
// Define a new struct that wraps WalletAuthStore
pub struct ProtonWalletAuthStore {
    pub(crate) inner: SimpleAuthStore,
}

impl ProtonWalletAuthStore {
    #[frb(sync)]
    pub fn new(env: &str) -> Result<Self, ApiError> {
        let auth = Arc::new(std::sync::Mutex::new(Auth::None));
        ProtonWalletAuthStore::from_auth(env, auth)
    }

    #[frb(ignore)]
    pub(crate) fn from_auth(
        env: &str,
        auth: Arc<std::sync::Mutex<Auth>>,
    ) -> Result<Self, ApiError> {
        let store = SimpleAuthStore::from_env_str(env, auth);
        Ok(Self { inner: store })
    }

    #[frb(sync)]
    pub fn from_session(
        env: &str,
        uid: String,
        access: String,
        refresh: String,
        scopes: Vec<String>,
    ) -> Result<Self, ApiError> {
        let auth = Auth::internal(uid, Tokens::access(access, refresh, scopes));
        ProtonWalletAuthStore::from_auth(env, Arc::new(std::sync::Mutex::new(auth)))
    }

    #[frb(sync)]
    pub fn set_auth_sync(
        &mut self,
        uid: String,
        access: String,
        refresh: String,
        scopes: Vec<String>,
    ) -> Result<(), ApiError> {
        let auth = Auth::internal(uid, Tokens::access(access, refresh, scopes));
        let _ = self.inner.set_auth(auth)?;
        Ok(())
    }

    #[frb(ignore)]
    pub(crate) fn update_auth(mut self, auth: Auth) -> Result<Self, ApiError> {
        let _ = self.inner.set_auth(auth)?;
        Ok(self)
    }

    pub async fn set_auth_dart_callback(
        &mut self,
        callback: impl Fn(ChildSession) -> DartFnFuture<String> + Send + Sync + 'static,
    ) -> Result<(), ApiError> {
        let mut cb = GLOBAL_SESSION_DART_CALLBACK.lock().await;
        *cb = Some(Arc::new(callback));
        info!("set_auth_dart_callback ok");
        Ok(())
    }

    pub async fn clear_auth_dart_callback(&self) -> Result<(), ApiError> {
        let mut cb = GLOBAL_SESSION_DART_CALLBACK.lock().await;
        *cb = None;
        info!("clear_auth_dart_callback ok");
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

    fn get_auth(&self) -> Result<Auth, StoreReadErr> {
        info!("ProtonWalletAuthStore get_auth");
        self.inner.get_auth()
    }

    fn set_auth(&mut self, auth: Auth) -> Result<Auth, StoreWriteErr> {
        info!("Custom set_auth: {:?}", auth.clone());
        self.refresh_auth_credential(auth.clone());
        self.inner.set_auth(auth)
    }
}

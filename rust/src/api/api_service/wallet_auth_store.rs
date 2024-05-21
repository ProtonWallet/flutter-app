use std::{future::Future, pin::Pin, sync::Arc};

use log::{debug, info};

use crate::{auth_store::AuthStoreExt, errors::ApiError};
use tokio::sync::Mutex;
pub type DartFnFuture<T> = Pin<Box<dyn Future<Output = T> + Send + 'static>>;
pub type DartCallback = dyn Fn(String) -> DartFnFuture<String> + Send + Sync;

// lazy_static::lazy_static! {
//     static ref GLOBAL_SESSION_UPDATE: Mutex<Option<Arc<DartCallback>>> = Mutex::new(None);
//     // static ref GLOBAL_SESSION_UPDATE_RUNTIME: Option<Arc<tokio::runtime::Runtime>> = None;
// }

// pub async fn set_session_update_delegate(
//     callback: impl Fn(String) -> DartFnFuture<String> + Send + Sync + 'static,
// ) -> Result<(), ApiError> {
//     let mut cb = GLOBAL_SESSION_UPDATE.lock().await;
//     *cb = Some(Arc::new(callback));
//     Ok(())
// }

pub struct ProtonWalletAuthStore {
    rt: tokio::runtime::Runtime,
    session: Mutex<Option<Arc<DartCallback>>>,
}

impl ProtonWalletAuthStore {
    pub fn new() -> Result<Self, ApiError> {
        match tokio::runtime::Builder::new_current_thread().build() {
            Ok(rt) => Ok(Self {
                rt,
                session: Mutex::new(None),
            }),
            Err(e) => Err(ApiError::Generic(format!(
                "Error creating runtime: {:?}",
                e
            ))),
        }
    }

    pub async fn set_dart_callback(
        &self,
        callback: impl Fn(String) -> DartFnFuture<String> + Send + Sync + 'static,
    ) -> Result<(), ApiError> {
        let mut cb = self.session.lock().await;
        *cb = Some(Arc::new(callback));
        Ok(())
    }

    pub fn test_callback(&self) {
        debug!("test_callback");
        self.refresh_auth_credential("Test Token".to_string())
    }
}

impl AuthStoreExt for ProtonWalletAuthStore {
    fn refresh_auth_credential(&self, message: String) {
        info!("refresh_auth_credential- start: {}", message);
        self.rt.block_on(async move {
            info!("refresh_auth_credential run block on");
            let cb = self.session.lock().await;
            if let Some(callback) = cb.as_ref() {
                info!("refresh_auth_credential found callback and calling it");
                let msg = callback(message).await;
                info!("refresh_auth_credential messageFromDart: {}", msg);
            }
        });
        info!("refresh_auth_credential- end");
    }
}

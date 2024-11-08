use std::sync::Arc;

use andromeda_api::proton_users::ProtonUserKey;
use flutter_rust_bridge::frb;

use crate::proton_wallet::{
    common::callbacks::DartFnFuture, storage::user_key::UserKeySecureStore,
};

// Define a new struct that wraps WalletAuthStore
pub struct FrbUserKeyStore {
    pub(crate) inner: UserKeySecureStore,
}

impl FrbUserKeyStore {
    #[frb(sync)]
    pub fn new() -> Self {
        FrbUserKeyStore {
            inner: UserKeySecureStore::new(),
        }
    }

    pub async fn set_get_default_user_key_callback(
        &mut self,
        callback: impl Fn(String) -> DartFnFuture<ProtonUserKey> + Send + Sync + 'static,
    ) {
        self.inner
            .set_get_default_user_key_callback(Arc::new(callback))
            .await
    }

    pub async fn set_get_passphrase_callback(
        &mut self,
        callback: impl Fn(String) -> DartFnFuture<String> + Send + Sync + 'static,
    ) {
        self.inner
            .set_get_user_key_passphrase_callback(Arc::new(callback))
            .await
    }

    pub async fn clear_auth_dart_callback(&self) {
        self.inner.clear().await;
    }
}

use std::sync::Arc;

use andromeda_api::wallet::ApiWalletKey;
use flutter_rust_bridge::frb;

use crate::proton_wallet::{
    common::callbacks::DartFnFuture, storage::wallet_key::WalletKeySecureStore,
};

// Define a new struct that wraps WalletAuthStore
pub struct FrbWalletKeyStore {
    pub(crate) inner: WalletKeySecureStore,
}

impl FrbWalletKeyStore {
    #[frb(sync)]
    pub fn new() -> Self {
        FrbWalletKeyStore {
            inner: WalletKeySecureStore::default(),
        }
    }

    pub async fn set_get_wallet_keys_callback(
        &mut self,
        callback: impl Fn() -> DartFnFuture<Vec<ApiWalletKey>> + Send + Sync + 'static,
    ) {
        self.inner
            .set_get_wallet_keys_callback(Arc::new(callback))
            .await
    }

    pub async fn set_save_wallet_keys_callback(
        &mut self,
        callback: impl Fn(Vec<ApiWalletKey>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) {
        self.inner
            .set_save_wallet_keys_callback(Arc::new(callback))
            .await
    }

    pub async fn clear_auth_dart_callback(&self) {
        self.inner.clear().await;
    }
}

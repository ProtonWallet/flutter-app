use flutter_rust_bridge::frb;
use std::sync::Arc;

use crate::proton_wallet::{
    common::callbacks::DartFnFuture,
    storage::{wallet_mnemonic::WalletMnemonicSecureStore, wallet_mnemonic_ext::MnemonicData},
};

// Define a new struct that wraps WalletAuthStore
pub struct FrbWalletMnemonicStore {
    pub(crate) inner: WalletMnemonicSecureStore,
}

impl FrbWalletMnemonicStore {
    #[frb(sync)]
    pub fn new() -> Self {
        FrbWalletMnemonicStore {
            inner: WalletMnemonicSecureStore::default(),
        }
    }

    pub async fn set_get_wallet_keys_callback(
        &mut self,
        callback: impl Fn() -> DartFnFuture<Vec<MnemonicData>> + Send + Sync + 'static,
    ) {
        self.inner
            .set_get_wallet_mnemonic_callback(Arc::new(callback))
            .await
    }

    pub async fn set_save_wallet_keys_callback(
        &mut self,
        callback: impl Fn(Vec<MnemonicData>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) {
        self.inner
            .set_save_wallet_mnemonic_callback(Arc::new(callback))
            .await
    }

    pub async fn clear_auth_dart_callback(&self) {
        self.inner.clear().await;
    }
}

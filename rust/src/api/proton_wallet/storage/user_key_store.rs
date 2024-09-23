use std::sync::Arc;

use andromeda_api::proton_users::ProtonUserKey;
use flutter_rust_bridge::frb;

use crate::{
    api::api_service::wallet_auth_store::DartFnFuture, proton_wallet::storage::user_key::UserKeyDao,
};

// Define a new struct that wraps WalletAuthStore
pub struct FrbUserKeyStore {
    pub(crate) inner: UserKeyDao,
}

impl FrbUserKeyStore {
    #[frb(sync)]
    pub fn new() -> Self {
        FrbUserKeyStore {
            inner: UserKeyDao::new(),
        }
    }

    pub async fn set_get_primary_user_key_callback(
        &mut self,
        callback: impl Fn(String) -> DartFnFuture<ProtonUserKey> + Send + Sync + 'static,
    ) {
        self.inner
            .set_get_primary_user_key_callback(Arc::new(callback))
            .await
    }

    pub async fn set_get_user_keys_callback(
        &mut self,
        callback: impl Fn(String) -> DartFnFuture<Vec<ProtonUserKey>> + Send + Sync + 'static,
    ) {
        self.inner
            .set_get_user_keys_callback(Arc::new(callback))
            .await
    }

    pub async fn clear_auth_dart_callback(&self) {
        self.inner.clear().await;
    }
}

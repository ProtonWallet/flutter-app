use andromeda_api::wallet::ApiWalletKey;
use async_trait::async_trait;
use std::sync::Arc;
use tokio::sync::Mutex;

use crate::proton_wallet::common::callbacks::{WalletKeysFetcher, WalletKeysSeter};

use super::error::WalletStorageError;

#[async_trait]
pub trait WalletKeyStore: Send + Sync {
    /// Fetch wallet keys associated with the given wallet ID
    async fn get_wallet_keys(&self) -> Result<Vec<ApiWalletKey>, WalletStorageError>;

    /// Save the given wallet keys
    async fn save_api_wallet_keys(
        &self,
        wallet_keys: Vec<ApiWalletKey>,
    ) -> Result<(), WalletStorageError>;
}

// Struct that stores wallet keys securely using Dart callbacks
pub struct WalletKeySecureStore {
    // Callbacks to fetch and save wallet keys, wrapped in Mutex for async safety
    pub(crate) get_wallet_keys_callback: Arc<Mutex<Option<Arc<WalletKeysFetcher>>>>,
    pub(crate) save_wallet_keys_callback: Arc<Mutex<Option<Arc<WalletKeysSeter>>>>,
}

impl Default for WalletKeySecureStore {
    fn default() -> Self {
        Self::new()
    }
}

impl WalletKeySecureStore {
    /// Create a new `WalletKeySecureStore` instance
    pub fn new() -> Self {
        WalletKeySecureStore {
            get_wallet_keys_callback: Arc::new(Mutex::new(None)),
            save_wallet_keys_callback: Arc::new(Mutex::new(None)),
        }
    }

    /// Set the callback for fetching wallet keys
    pub async fn set_get_wallet_keys_callback(&self, callback: Arc<WalletKeysFetcher>) {
        let mut cached_callback = self.get_wallet_keys_callback.lock().await;
        *cached_callback = Some(callback);
    }

    /// Set the callback for saving wallet keys
    pub async fn set_save_wallet_keys_callback(&self, callback: Arc<WalletKeysSeter>) {
        let mut cached_callback = self.save_wallet_keys_callback.lock().await;
        *cached_callback = Some(callback);
    }

    /// Clear the stored callbacks
    pub async fn clear(&self) {
        let mut cb = self.get_wallet_keys_callback.lock().await;
        *cb = None;
        let mut cb = self.save_wallet_keys_callback.lock().await;
        *cb = None;
    }
}

#[async_trait]
impl WalletKeyStore for WalletKeySecureStore {
    /// Fetch wallet keys for a specific wallet ID
    async fn get_wallet_keys(&self) -> Result<Vec<ApiWalletKey>, WalletStorageError> {
        let cb = self.get_wallet_keys_callback.lock().await;
        if let Some(callback) = cb.as_ref() {
            let keys = callback().await;
            Ok(keys)
        } else {
            // Return an error if no callback is set
            Err(WalletStorageError::CallbackNotSet)
        }
    }

    /// Save the wallet keys using the callback
    async fn save_api_wallet_keys(
        &self,
        wallet_keys: Vec<ApiWalletKey>,
    ) -> Result<(), WalletStorageError> {
        let cb = self.save_wallet_keys_callback.lock().await;
        if let Some(callback) = cb.as_ref() {
            callback(wallet_keys).await;
            Ok(())
        } else {
            // Return an error if no callback is set
            Err(WalletStorageError::CallbackNotSet)
        }
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
pub mod mock {
    use super::*;
    use async_trait::async_trait;
    use mockall::mock;
    mock! {
        pub WalletKeySecureStore {}
        #[async_trait]
        impl WalletKeyStore for WalletKeySecureStore {
            async fn get_wallet_keys(&self) -> Result<Vec<ApiWalletKey>, WalletStorageError>;
            async fn save_api_wallet_keys(&self, wallet_keys: Vec<ApiWalletKey>) -> Result<(), WalletStorageError>;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::proton_wallet::common::callbacks::DartFnFuture;
    use andromeda_api::wallet::ApiWalletKey;
    use std::sync::Arc;

    // Mock function for fetching wallet keys
    fn mock_wallet_keys_fetcher() -> DartFnFuture<Vec<ApiWalletKey>> {
        Box::pin(async { vec![ApiWalletKey::default()] })
    }

    // Mock function for saving wallet keys
    fn mock_wallet_keys_setter(_: Vec<ApiWalletKey>) -> DartFnFuture<()> {
        Box::pin(async {})
    }

    #[tokio::test]
    async fn test_get_wallet_keys_success() {
        let store = WalletKeySecureStore::new();

        let wallet_keys_callback: Arc<WalletKeysFetcher> = Arc::new(mock_wallet_keys_fetcher);
        store
            .set_get_wallet_keys_callback(wallet_keys_callback)
            .await;

        let result = store.get_wallet_keys().await;
        assert!(result.is_ok());

        let keys = result.unwrap();
        assert!(!keys.is_empty());
    }

    #[tokio::test]
    async fn test_get_wallet_keys_callback_not_set() {
        let store = WalletKeySecureStore::new();

        let result = store.get_wallet_keys().await;
        assert!(result.is_err());
        assert_eq!(result.err().unwrap(), WalletStorageError::CallbackNotSet);
    }

    #[tokio::test]
    async fn test_save_wallet_keys_success() {
        let store = WalletKeySecureStore::new();

        let wallet_keys_callback: Arc<WalletKeysSeter> = Arc::new(mock_wallet_keys_setter);
        store
            .set_save_wallet_keys_callback(wallet_keys_callback)
            .await;

        let keys = vec![ApiWalletKey::default()];
        let result = store.save_api_wallet_keys(keys).await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_save_wallet_keys_callback_not_set() {
        let store = WalletKeySecureStore::new();

        let keys = vec![ApiWalletKey::default()];
        let result = store.save_api_wallet_keys(keys).await;
        assert!(result.is_err());
        assert_eq!(result.err().unwrap(), WalletStorageError::CallbackNotSet);
    }

    #[tokio::test]
    async fn test_clear_callbacks() {
        let store = WalletKeySecureStore::default();

        let wallet_keys_callback: Arc<WalletKeysFetcher> = Arc::new(mock_wallet_keys_fetcher);
        store
            .set_get_wallet_keys_callback(wallet_keys_callback)
            .await;

        let result = store.get_wallet_keys().await;
        assert!(result.is_ok());

        store.clear().await;

        let result = store.get_wallet_keys().await;
        assert!(result.is_err());
        assert_eq!(result.err().unwrap(), WalletStorageError::CallbackNotSet);
    }
}

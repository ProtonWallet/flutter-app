use async_trait::async_trait;
use std::sync::Arc;
use tokio::sync::Mutex;

use crate::proton_wallet::common::callbacks::{WalletMnemonicFetcher, WalletMnemonicSeter};

use super::error::WalletStorageError;

#[async_trait]
pub trait WalletMnemonicStore: Send + Sync {
    /// Fetch wallet mnemonic associated with the given wallet ID
    async fn get_wallet_mnemonic(&self, wallet_id: String) -> Result<String, WalletStorageError>;

    /// Save the given wallet mnemonic
    async fn save_api_wallet_mnemonic(
        &self,
        wallet_mnemonics: Vec<String>,
    ) -> Result<(), WalletStorageError>;
}

// Struct that stores wallet mnemonic securely using Dart callbacks
pub struct WalletMnemonicSecureStore {
    // Callbacks to fetch and save wallet mnemonic, wrapped in Mutex for async safety
    pub(crate) get_wallet_mnemonic_callback: Arc<Mutex<Option<Arc<WalletMnemonicFetcher>>>>,
    pub(crate) save_wallet_mnemonic_callback: Arc<Mutex<Option<Arc<WalletMnemonicSeter>>>>,
}

impl Default for WalletMnemonicSecureStore {
    fn default() -> Self {
        Self::new()
    }
}

impl WalletMnemonicSecureStore {
    /// Create a new `WalletMnemonicSecureStore` instance
    pub fn new() -> Self {
        WalletMnemonicSecureStore {
            get_wallet_mnemonic_callback: Arc::new(Mutex::new(None)),
            save_wallet_mnemonic_callback: Arc::new(Mutex::new(None)),
        }
    }

    /// Set the callback for fetching wallet mnemonic
    pub async fn set_get_wallet_mnemonic_callback(&self, callback: Arc<WalletMnemonicFetcher>) {
        let mut cached_callback = self.get_wallet_mnemonic_callback.lock().await;
        *cached_callback = Some(callback);
    }

    /// Set the callback for saving wallet mnemonic
    pub async fn set_save_wallet_mnemonic_callback(&self, callback: Arc<WalletMnemonicSeter>) {
        let mut cached_callback = self.save_wallet_mnemonic_callback.lock().await;
        *cached_callback = Some(callback);
    }

    /// Clear the stored callbacks
    pub async fn clear(&self) {
        let mut cb = self.get_wallet_mnemonic_callback.lock().await;
        *cb = None;
        let mut cb = self.save_wallet_mnemonic_callback.lock().await;
        *cb = None;
    }
}

#[async_trait]
impl WalletMnemonicStore for WalletMnemonicSecureStore {
    /// Fetch wallet mnemonic for a specific wallet ID
    async fn get_wallet_mnemonic(&self, wallet_id: String) -> Result<String, WalletStorageError> {
        let cb = self.get_wallet_mnemonic_callback.lock().await;
        if let Some(callback) = cb.as_ref() {
            let mnemonic = callback(wallet_id).await;
            Ok(mnemonic)
        } else {
            // Return an error if no callback is set
            Err(WalletStorageError::CallbackNotSet)
        }
    }

    /// Save the wallet mnemonic using the callback
    async fn save_api_wallet_mnemonic(
        &self,
        wallet_mnemonics: Vec<String>,
    ) -> Result<(), WalletStorageError> {
        let cb = self.save_wallet_mnemonic_callback.lock().await;
        if let Some(callback) = cb.as_ref() {
            callback(wallet_mnemonics).await;
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
        pub WalletMnemonicStore {}
        #[async_trait]
        impl WalletMnemonicStore for WalletMnemonicStore {
            async fn get_wallet_mnemonic(&self, wallet_id: String) -> Result<String, WalletStorageError>;
            async fn save_api_wallet_mnemonic(&self, wallet_mnemonics: Vec<String>) -> Result<(), WalletStorageError>;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::proton_wallet::common::callbacks::DartFnFuture;
    use std::sync::Arc;

    // Mock function for fetching wallet mnemonic
    fn mock_wallet_mnemonic_fetcher(wallet_id: String) -> DartFnFuture<String> {
        assert!(wallet_id == "test_wallet_id");
        Box::pin(async { "test_mnemonic".to_owned() })
    }

    // Mock function for saving wallet mnemonic
    fn mock_wallet_mnemonic_setter(_: Vec<String>) -> DartFnFuture<()> {
        Box::pin(async {})
    }

    #[tokio::test]
    async fn test_get_wallet_mnemonic_success() {
        let store = WalletMnemonicSecureStore::new();
        let wallet_mnemonic_callback = Arc::new(mock_wallet_mnemonic_fetcher);
        store
            .set_get_wallet_mnemonic_callback(wallet_mnemonic_callback)
            .await;

        let result = store.get_wallet_mnemonic("test_wallet_id".to_owned()).await;
        assert!(result.is_ok());
        let mnemonic = result.unwrap();
        assert!(!mnemonic.is_empty());
        assert!(mnemonic == "test_mnemonic");
    }

    #[tokio::test]
    async fn test_get_wallet_mnemonic_callback_not_set() {
        let store = WalletMnemonicSecureStore::new();
        let result = store.get_wallet_mnemonic("test_wallet_id".to_owned()).await;
        assert!(result.is_err());
        assert_eq!(result.err().unwrap(), WalletStorageError::CallbackNotSet);
    }

    #[tokio::test]
    async fn test_save_wallet_mnemonic_success() {
        let store = WalletMnemonicSecureStore::new();
        let wallet_mnemonic_callback: Arc<WalletMnemonicSeter> =
            Arc::new(mock_wallet_mnemonic_setter);
        store
            .set_save_wallet_mnemonic_callback(wallet_mnemonic_callback)
            .await;
        let mnemonics = vec![String::default()];
        let result = store.save_api_wallet_mnemonic(mnemonics).await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_save_wallet_mnemonic_callback_not_set() {
        let store = WalletMnemonicSecureStore::new();
        let mnemonics = vec![String::default()];
        let result = store.save_api_wallet_mnemonic(mnemonics).await;
        assert!(result.is_err());
        assert_eq!(result.err().unwrap(), WalletStorageError::CallbackNotSet);
    }

    #[tokio::test]
    async fn test_clear_callbacks() {
        let store = WalletMnemonicSecureStore::default();
        let wallet_mnemonic_callback = Arc::new(mock_wallet_mnemonic_fetcher);
        store
            .set_get_wallet_mnemonic_callback(wallet_mnemonic_callback)
            .await;
        let result = store.get_wallet_mnemonic("test_wallet_id".to_owned()).await;
        assert!(result.is_ok());
        store.clear().await;
        let result = store.get_wallet_mnemonic("test_wallet_id".to_owned()).await;
        assert!(result.is_err());
        assert_eq!(result.err().unwrap(), WalletStorageError::CallbackNotSet);
    }
}

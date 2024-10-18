use async_trait::async_trait;
use std::sync::Arc;
use tokio::sync::Mutex;

use proton_crypto_account::{
    keys::{LockedKey, UserKeys},
    salts::KeySecret,
};

use crate::proton_wallet::common::callbacks::{
    UserKeyFetcher, UserKeyPassphraseFetcher, UserKeysFetcher,
};

use super::{
    error::WalletStorageError,
    user_key_ext::{user_key_conversion_from_key, user_key_conversion_from_keys},
};

#[async_trait]
pub trait UserKeyStore: Send + Sync + 'static {
    /// Fetches all user keys for a given user ID
    async fn get_user_keys(&self, user_id: String) -> Result<UserKeys, WalletStorageError>;

    /// Fetches the primary user key for a given user ID
    async fn get_primary_user_key(&self, user_id: String) -> Result<LockedKey, WalletStorageError>;

    /// Fetches the user key passphrase for a given user ID
    async fn get_user_key_passphrase(
        &self,
        user_id: String,
    ) -> Result<KeySecret, WalletStorageError>;
}

// A struct that implements `UserKeyStore` using callbacks to interact with Dart
pub struct UserKeySecureStore {
    // Arc-wrapped Mutex to safely manage async access to the fetch callbacks
    pub(crate) get_user_keys_callback: Arc<Mutex<Option<Arc<UserKeysFetcher>>>>,
    pub(crate) get_primary_user_key_callback: Arc<Mutex<Option<Arc<UserKeyFetcher>>>>,
    pub(crate) get_user_key_passphrase_callback: Arc<Mutex<Option<Arc<UserKeyPassphraseFetcher>>>>,
}

impl Default for UserKeySecureStore {
    fn default() -> Self {
        Self::new()
    }
}

impl UserKeySecureStore {
    /// Creates a new `UserKeySecureStore` instance
    pub fn new() -> Self {
        UserKeySecureStore {
            get_user_keys_callback: Arc::new(Mutex::new(None)),
            get_primary_user_key_callback: Arc::new(Mutex::new(None)),
            get_user_key_passphrase_callback: Arc::new(Mutex::new(None)),
        }
    }

    /// Sets the callback for fetching all user keys
    pub async fn set_get_user_keys_callback(&self, callback: Arc<UserKeysFetcher>) {
        let mut cached_callback = self.get_user_keys_callback.lock().await;
        *cached_callback = Some(callback);
    }

    /// Sets the callback for fetching the primary user key
    pub async fn set_get_primary_user_key_callback(&self, callback: Arc<UserKeyFetcher>) {
        let mut cached_callback = self.get_primary_user_key_callback.lock().await;
        *cached_callback = Some(callback);
    }

    /// Sets the callback for fetching the user key passphrase
    pub async fn set_get_user_key_passphrase_callback(
        &self,
        callback: Arc<UserKeyPassphraseFetcher>,
    ) {
        let mut cached_callback = self.get_user_key_passphrase_callback.lock().await;
        *cached_callback = Some(callback);
    }

    /// Clears all user key fetch callbacks
    pub async fn clear(&self) {
        let mut cb = self.get_user_keys_callback.lock().await;
        *cb = None;
        let mut cb = self.get_primary_user_key_callback.lock().await;
        *cb = None;
        let mut cb = self.get_user_key_passphrase_callback.lock().await;
        *cb = None;
    }
}

#[async_trait]
impl UserKeyStore for UserKeySecureStore {
    /// Fetches all user keys for a given user ID by invoking the callback
    async fn get_user_keys(&self, user_id: String) -> Result<UserKeys, WalletStorageError> {
        let cb = self.get_user_keys_callback.lock().await;
        if let Some(callback) = cb.as_ref() {
            let keys = callback(user_id).await;
            Ok(user_key_conversion_from_keys(keys))
        } else {
            // Return an error if the callback is not set
            Err(WalletStorageError::CallbackNotSet)
        }
    }

    /// Fetches the primary user key for a given user ID by invoking the callback
    async fn get_primary_user_key(&self, user_id: String) -> Result<LockedKey, WalletStorageError> {
        let cb = self.get_primary_user_key_callback.lock().await;
        if let Some(callback) = cb.as_ref() {
            let key = callback(user_id).await;
            Ok(user_key_conversion_from_key(key))
        } else {
            // Return an error if the callback is not set
            Err(WalletStorageError::CallbackNotSet)
        }
    }

    /// Fetches the user key passphrase for a given user ID by invoking the callback
    async fn get_user_key_passphrase(
        &self,
        user_id: String,
    ) -> Result<KeySecret, WalletStorageError> {
        let cb = self.get_user_key_passphrase_callback.lock().await;
        if let Some(callback) = cb.as_ref() {
            let key_passphrase = callback(user_id).await;
            Ok(KeySecret::new(key_passphrase.as_bytes().to_vec()))
        } else {
            // Return an error if the callback is not set
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
        pub UserKeySecureStore {}
        #[async_trait]
        impl UserKeyStore for UserKeySecureStore {
            async fn get_user_keys(&self, user_id: String) -> Result<UserKeys, WalletStorageError>;
            async fn get_primary_user_key(&self, user_id: String) -> Result<LockedKey, WalletStorageError>;
            async fn get_user_key_passphrase(&self, user_id: String) -> Result<KeySecret, WalletStorageError>;
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::mocks::user_keys::tests::mock_fake_proton_user_key;

    use super::*;

    // Test case for fetching user keys successfully
    #[tokio::test]
    async fn test_get_user_keys_success() {
        let store = UserKeySecureStore::default();
        let user_id = "test_user_id".to_string();
        let user_keys_callback: Arc<UserKeysFetcher> =
            Arc::new(move |_| Box::pin(async move { vec![mock_fake_proton_user_key()] }));
        store.set_get_user_keys_callback(user_keys_callback).await;

        let result = store.get_user_keys(user_id.clone()).await.unwrap();
        assert!(!result.0.is_empty());
        let key = result.0.first().unwrap();
        assert_eq!(key.id, "test_id".into());
    }

    // Test case for fetching the primary user key successfully
    #[tokio::test]
    async fn test_get_primary_user_key_success() {
        let store = UserKeySecureStore::new();
        let user_id = "test_user_id".to_string();
        let primary_key_callback: Arc<UserKeyFetcher> =
            Arc::new(move |_| Box::pin(async move { mock_fake_proton_user_key() }));
        store
            .set_get_primary_user_key_callback(primary_key_callback)
            .await;

        let result = store.get_primary_user_key(user_id.clone()).await;
        assert!(result.is_ok());
        let locked_key = result.unwrap();
        assert_eq!(locked_key.id, "test_id".into());
    }

    // Test case for fetching the user key passphrase successfully
    #[tokio::test]
    async fn test_get_user_key_passphrase_success() {
        let store = UserKeySecureStore::new();
        let user_id = "test_user_id".to_string();
        let passphrase_callback: Arc<UserKeyPassphraseFetcher> =
            Arc::new(move |_| Box::pin(async move { "test_passphrase".to_string() }));
        store
            .set_get_user_key_passphrase_callback(passphrase_callback)
            .await;

        let result = store.get_user_key_passphrase(user_id.clone()).await;
        assert!(result.is_ok());
        let passphrase = result.unwrap();
        assert_eq!(passphrase.as_bytes(), b"test_passphrase");
    }

    // Test case for error when user keys callback is not set
    #[tokio::test]
    async fn test_get_user_keys_callback_not_set() {
        let store = UserKeySecureStore::new();
        let user_id = "test_user_id".to_string();
        let result = store.get_user_keys(user_id).await;
        assert!(result.is_err());
        assert_eq!(result.err().unwrap(), WalletStorageError::CallbackNotSet);
    }

    // Test case for error when primary user key callback is not set
    #[tokio::test]
    async fn test_get_primary_user_key_callback_not_set() {
        let store = UserKeySecureStore::default();
        let user_id = "test_user_id".to_string();
        let result = store.get_primary_user_key(user_id).await;
        assert!(result.is_err());
        assert_eq!(result.err().unwrap(), WalletStorageError::CallbackNotSet);
    }

    // Test case for clearing all callbacks
    #[tokio::test]
    async fn test_clear_callbacks() {
        let store = UserKeySecureStore::new();
        let user_id = "test_user_id".to_string();
        let user_keys_callback: Arc<UserKeysFetcher> =
            Arc::new(move |_| Box::pin(async move { vec![mock_fake_proton_user_key()] }));
        store.set_get_user_keys_callback(user_keys_callback).await;

        let result = store.get_user_keys(user_id.clone()).await.unwrap();
        assert!(!result.0.is_empty());
        let key = result.0.first().unwrap();
        assert_eq!(key.id, "test_id".into());

        // Clear the callbacks
        store.clear().await;

        // After clearing, the callbacks should return an error
        let result = store.get_primary_user_key(user_id).await;
        assert!(result.is_err());
        assert_eq!(result.err().unwrap(), WalletStorageError::CallbackNotSet);
    }
}

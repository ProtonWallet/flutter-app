use async_trait::async_trait;
use proton_crypto_account::{keys::LockedKey, salts::KeySecret};
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{error::WalletStorageError, user_key_ext::user_key_conversion_from_key, Result};
use crate::proton_wallet::common::callbacks::{UserKeyFetcher, UserKeyPassphraseFetcher};

#[async_trait]
pub trait UserKeyStore: Send + Sync + 'static {
    /// Fetches the default user key for a given user ID
    async fn get_default_user_key(&self, user_id: String) -> Result<LockedKey>;

    /// Fetches the user key passphrase for a given user ID
    async fn get_user_key_passphrase(&self, user_id: String) -> Result<KeySecret>;
}

// A struct that implements `UserKeyStore` using callbacks to interact with Dart
pub struct UserKeySecureStore {
    // Arc-wrapped Mutex to safely manage async access to the fetch callbacks
    pub(crate) get_default_user_key_callback: Arc<Mutex<Option<Arc<UserKeyFetcher>>>>,
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
            get_default_user_key_callback: Arc::new(Mutex::new(None)),
            get_user_key_passphrase_callback: Arc::new(Mutex::new(None)),
        }
    }

    /// Sets the callback for fetching the default user key
    pub async fn set_get_default_user_key_callback(&self, callback: Arc<UserKeyFetcher>) {
        let mut cached_callback = self.get_default_user_key_callback.lock().await;
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
        let mut cb = self.get_default_user_key_callback.lock().await;
        *cb = None;
        let mut cb = self.get_user_key_passphrase_callback.lock().await;
        *cb = None;
    }
}

#[async_trait]
impl UserKeyStore for UserKeySecureStore {
    /// Fetches the default user key for a given user ID by invoking the callback
    async fn get_default_user_key(&self, user_id: String) -> Result<LockedKey> {
        let cb = self.get_default_user_key_callback.lock().await;
        if let Some(callback) = cb.as_ref() {
            let key = callback(user_id).await;
            Ok(user_key_conversion_from_key(key))
        } else {
            // Return an error if the callback is not set
            Err(WalletStorageError::CallbackNotSet(
                "Get default user".to_owned(),
            ))
        }
    }

    /// Fetches the user key passphrase for a given user ID by invoking the callback
    async fn get_user_key_passphrase(&self, user_id: String) -> Result<KeySecret> {
        let cb = self.get_user_key_passphrase_callback.lock().await;
        if let Some(callback) = cb.as_ref() {
            let key_passphrase = callback(user_id).await;
            Ok(KeySecret::new(key_passphrase.as_bytes().to_vec()))
        } else {
            // Return an error if the callback is not set
            Err(WalletStorageError::CallbackNotSet(
                "Get user key passphrase".to_owned(),
            ))
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
            // async fn get_user_keys(&self, user_id: String) -> Result<UserKeys>;
            async fn get_default_user_key(&self, user_id: String) -> Result<LockedKey>;
            async fn get_user_key_passphrase(&self, user_id: String) -> Result<KeySecret>;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::mocks::user_keys::tests::mock_fake_proton_user_key;

    // Test case for fetching the default user key successfully
    #[tokio::test]
    async fn test_get_default_user_key_success() {
        let store = UserKeySecureStore::new();
        let user_id = "test_user_id".to_string();
        let default_key_callback: Arc<UserKeyFetcher> =
            Arc::new(move |_| Box::pin(async move { mock_fake_proton_user_key() }));
        store
            .set_get_default_user_key_callback(default_key_callback)
            .await;

        let result = store.get_default_user_key(user_id.clone()).await;
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

    // Test case for error when default user key callback is not set
    #[tokio::test]
    async fn test_get_default_user_key_callback_not_set() {
        let store = UserKeySecureStore::default();
        let user_id = "test_user_id".to_string();
        let result = store.get_default_user_key(user_id).await;
        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap(),
            WalletStorageError::CallbackNotSet("Get default user".to_owned())
        );
    }

    // Test case for clearing all callbacks
    #[tokio::test]
    async fn test_clear_callbacks() {
        let store = UserKeySecureStore::new();
        let user_id = "test_id".to_string();

        let default_key_callback: Arc<UserKeyFetcher> =
            Arc::new(move |_| Box::pin(async move { mock_fake_proton_user_key() }));
        store
            .set_get_default_user_key_callback(default_key_callback)
            .await;

        let result = store.get_default_user_key(user_id.clone()).await;
        assert!(result.is_ok());
        let key = result.unwrap();
        assert_eq!(key.id, "test_id".into());

        // Clear the callbacks
        store.clear().await;

        // After clearing, the callbacks should return an error
        let result = store.get_default_user_key(user_id.clone()).await;
        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap(),
            WalletStorageError::CallbackNotSet("Get default user".to_string())
        );

        let result = store.get_user_key_passphrase(user_id).await;
        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap(),
            WalletStorageError::CallbackNotSet("Get user key passphrase".to_string())
        );
    }
}

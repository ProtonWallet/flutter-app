use andromeda_api::proton_users::ProtonUserKey;
use async_trait::async_trait;
use std::{future::Future, pin::Pin, sync::Arc};
use tokio::sync::Mutex;

use proton_crypto_account::keys::{LockedKey, UserKeys};

use super::{
    error::WalletStorageError,
    user_key_ext::{user_key_conversion_from_key, user_key_conversion_from_keys},
};
pub type DartFnFuture<T> = Pin<Box<dyn Future<Output = T> + Send + 'static>>;
pub type UserKeysFetcher = dyn Fn(String) -> DartFnFuture<Vec<ProtonUserKey>> + Send + Sync;
pub type UserKeyFetcher = dyn Fn(String) -> DartFnFuture<ProtonUserKey> + Send + Sync;

#[async_trait]
pub trait UserKeyStore: Send + Sync + 'static {
    async fn get_user_keys(&self, user_id: String) -> Result<UserKeys, WalletStorageError>;
    async fn get_primary_user_key(&self, user_id: String) -> Result<LockedKey, WalletStorageError>;
}

// Struct that implements the `UserKeyStore` and caches the Dart callback
pub struct UserKeyDao {
    get_user_keys: Arc<Mutex<Option<Arc<UserKeysFetcher>>>>,
    get_primary_user_key: Arc<Mutex<Option<Arc<UserKeyFetcher>>>>,
}

impl Default for UserKeyDao {
    fn default() -> Self {
        Self::new()
    }
}

impl UserKeyDao {
    pub fn new() -> Self {
        UserKeyDao {
            get_user_keys: Arc::new(Mutex::new(None)),
            get_primary_user_key: Arc::new(Mutex::new(None)),
        }
    }

    pub async fn set_get_user_keys_callback(&self, callback: Arc<UserKeysFetcher>) {
        let mut cached_callback = self.get_user_keys.lock().await;
        *cached_callback = Some(callback);
    }

    pub async fn set_get_primary_user_key_callback(&self, callback: Arc<UserKeyFetcher>) {
        let mut cached_callback = self.get_primary_user_key.lock().await;
        *cached_callback = Some(callback);
    }

    pub async fn clear(&self) {
        let mut cb = self.get_user_keys.lock().await;
        *cb = None;
        let mut cb = self.get_primary_user_key.lock().await;
        *cb = None;
    }
}

#[async_trait]
impl UserKeyStore for UserKeyDao {
    async fn get_user_keys(&self, user_id: String) -> Result<UserKeys, WalletStorageError> {
        let cb = self.get_user_keys.lock().await;
        if let Some(callback) = cb.as_ref() {
            let keys = callback(user_id).await;
            Ok(user_key_conversion_from_keys(keys))
        } else {
            // Return an error if no callback is set
            Err(WalletStorageError::CallbackNotSet)
        }
    }

    async fn get_primary_user_key(&self, user_id: String) -> Result<LockedKey, WalletStorageError> {
        let cb = self.get_primary_user_key.lock().await;
        if let Some(callback) = cb.as_ref() {
            let key = callback(user_id).await;
            Ok(user_key_conversion_from_key(key))
        } else {
            // Return an error if no callback is set
            Err(WalletStorageError::CallbackNotSet)
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::mocks::user_keys::tests::mock_fake_proton_user_key;

    use super::*;

    #[tokio::test]
    async fn test_get_user_keys_success() {
        let dao = UserKeyDao::new();
        let user_id = "test_user_id".to_string();
        let user_keys_callback: Arc<UserKeysFetcher> =
            Arc::new(move |_| Box::pin(async move { vec![mock_fake_proton_user_key()] }));
        dao.set_get_user_keys_callback(user_keys_callback).await;
        let result = dao.get_user_keys(user_id.clone()).await.unwrap();
        assert!(!result.0.is_empty());
        let key = result.0.first().unwrap();
        assert_eq!(key.id, "test_id".into());
    }

    #[tokio::test]
    async fn test_get_primary_user_key_success() {
        let dao = UserKeyDao::new();
        let user_id = "test_user_id".to_string();
        let primary_key_callback: Arc<UserKeyFetcher> =
            Arc::new(move |_| Box::pin(async move { mock_fake_proton_user_key() }));
        dao.set_get_primary_user_key_callback(primary_key_callback)
            .await;
        let result = dao.get_primary_user_key(user_id.clone()).await;
        assert!(result.is_ok());
        let locked_key = result.unwrap();
        assert_eq!(locked_key.id, "test_id".into());
    }

    #[tokio::test]
    async fn test_get_user_keys_callback_not_set() {
        let dao = UserKeyDao::new();
        let user_id = "test_user_id".to_string();
        let result = dao.get_user_keys(user_id).await;
        assert!(result.is_err());
        assert_eq!(result.err().unwrap(), WalletStorageError::CallbackNotSet);
    }

    #[tokio::test]
    async fn test_get_primary_user_key_callback_not_set() {
        let dao = UserKeyDao::new();
        let user_id = "test_user_id".to_string();
        let result = dao.get_primary_user_key(user_id).await;
        assert!(result.is_err());
        assert_eq!(result.err().unwrap(), WalletStorageError::CallbackNotSet);
    }

    #[tokio::test]
    async fn test_clean() {
        let dao = UserKeyDao::new();
        let user_id = "test_user_id".to_string();
        let user_keys_callback: Arc<UserKeysFetcher> =
            Arc::new(move |_| Box::pin(async move { vec![mock_fake_proton_user_key()] }));
        dao.set_get_user_keys_callback(user_keys_callback).await;
        let result = dao.get_user_keys(user_id.clone()).await.unwrap();
        assert!(!result.0.is_empty());
        let key = result.0.first().unwrap();
        assert_eq!(key.id, "test_id".into());
        dao.clear().await;
        let result = dao.get_primary_user_key(user_id).await;
        assert!(result.is_err());
        assert_eq!(result.err().unwrap(), WalletStorageError::CallbackNotSet);
    }
}

use async_trait::async_trait;
use std::{collections::HashMap, sync::Arc};
use tokio::sync::Mutex;

use super::{error::ProviderError, user_keys::UserKeysProvider, Result};
use crate::{
    api::crypto::wallet_key::UnlockedWalletKey,
    proton_wallet::{
        crypto::{private_key::LockedPrivateKeys, wallet_key::LockedWalletKey},
        storage::wallet_key::WalletKeyStore,
    },
};
use andromeda_api::{wallet::ApiWalletKey, wallet_ext::WalletClientExt};
use proton_crypto::new_pgp_provider;

/// Implementation of the wallet keys provider that handles key retrieval, unlocking, and caching.
pub struct WalletKeysProviderImpl {
    /// Provides user keys required for unlocking wallet keys.
    pub(crate) user_key_provider: Arc<dyn UserKeysProvider>,

    /// Secure store for wallet keys.
    pub(crate) wallet_key_store: Arc<dyn WalletKeyStore>,

    /// Wallet API client for communicating with external wallet services.
    pub(crate) wallet_client: Arc<dyn WalletClientExt + Send + Sync>,

    /// In-memory cache for wallet keys.
    pub(crate) wallet_keys: Arc<Mutex<Option<Vec<ApiWalletKey>>>>,
}

/// Trait for managing wallet keys, including unlocking and resetting the key cache.
#[async_trait]
pub trait WalletKeysProvider: Send + Sync {
    /// Get and decrypt the wallet key from the secure store using the user key.
    async fn get_unlocked_wallet_key(&self, wallet_id: &str) -> Result<UnlockedWalletKey>;

    /// Clears the in-memory cache.
    async fn clear(&self);

    /// Resets the wallet keys provider by clearing the cache and fetching from the server.
    async fn reset(&self) -> Result<()>;
}

#[async_trait]
impl WalletKeysProvider for WalletKeysProviderImpl {
    /// Get and decrypt the wallet key from the secure store using the user key.
    async fn get_unlocked_wallet_key(&self, wallet_id: &str) -> Result<UnlockedWalletKey> {
        // Fetch the locked wallet key from the secure store or cache
        let locked_wallet_key = self.get_locked_wallet_key(wallet_id).await?;

        // Fetch user keys and passphrase
        let user_keys = self.user_key_provider.get_user_keys().await?;
        let locked_private_keys = LockedPrivateKeys::from_user_keys(user_keys);
        let key_secret = self.user_key_provider.get_user_key_passphrase().await?;

        // Unlock the user keys and wallet key
        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_private_keys.unlock_with(&provider, &key_secret);
        let unlocked_wallet_key =
            locked_wallet_key.unlock_with(&provider, unlocked_private_keys.user_keys)?;

        // Return the decrypted wallet key
        Ok(unlocked_wallet_key)
    }

    /// Clears the in-memory cache of wallet keys.
    async fn clear(&self) {
        let mut mut_wallet_keys = self.wallet_keys.lock().await;
        *mut_wallet_keys = None;
    }

    /// Resets the wallet keys provider by clearing the cache and fetching fresh keys from the server.
    async fn reset(&self) -> Result<()> {
        self.clear().await;
        self.fetch_from_server().await?;
        Ok(())
    }
}

impl WalletKeysProviderImpl {
    /// Creates a new instance of `WalletKeysProviderImpl`.
    pub fn new(
        user_key_provider: Arc<dyn UserKeysProvider>,
        wallet_key_store: Arc<dyn WalletKeyStore>,
        wallet_client: Arc<dyn WalletClientExt + Send + Sync>,
    ) -> Self {
        WalletKeysProviderImpl {
            user_key_provider,
            wallet_key_store,
            wallet_client,
            wallet_keys: Arc::new(Mutex::new(None)),
        }
    }

    /// Fetch the locked wallet key from memory, secure store, or server.
    async fn get_locked_wallet_key(&self, wallet_id: &str) -> Result<LockedWalletKey> {
        // Try fetching from memory
        if let Some(wallet_key) = self.find_from_memory(wallet_id).await {
            return Ok(wallet_key.into());
        }

        // Try fetching from the secure store
        self.load_wallet_keys_from_store().await?;
        if let Some(wallet_key) = self.find_from_memory(wallet_id).await {
            return Ok(wallet_key.into());
        }

        // Try fetching from the server
        self.fetch_from_server().await?;
        if let Some(wallet_key) = self.find_from_memory(wallet_id).await {
            return Ok(wallet_key.into());
        }

        Err(ProviderError::WalletKeyNotFound)
    }

    /// Search for the wallet key in the in-memory cache.
    async fn find_from_memory(&self, wallet_id: &str) -> Option<ApiWalletKey> {
        let mut_wallet_keys = self.wallet_keys.lock().await;
        // Check if wallet_keys contains Some(Vec<ApiWalletKey>), and if so, search in the vector
        if let Some(wallet_keys) = mut_wallet_keys.as_ref() {
            wallet_keys
                .iter()
                .find(|key| key.WalletID == wallet_id)
                .cloned()
        } else {
            None // Return None if the in-memory cache is empty
        }
    }

    /// Load wallet keys from the secure store and update the in-memory cache.
    async fn load_wallet_keys_from_store(&self) -> Result<Vec<ApiWalletKey>> {
        let wallet_keys = self.wallet_key_store.get_wallet_keys().await?;
        let mut mut_wallet_keys = self.wallet_keys.lock().await;
        *mut_wallet_keys = Some(wallet_keys.clone());
        Ok(wallet_keys)
    }

    /// Fetch wallet keys from the server and update the secure store and cache.
    async fn fetch_from_server(&self) -> Result<()> {
        let api_wallets = self.wallet_client.get_wallets().await?;
        let api_wallet_keys = api_wallets
            .iter()
            .map(|w| w.WalletKey.clone())
            .collect::<Vec<_>>();
        self.save_api_wallet_keys(api_wallet_keys).await?;
        Ok(())
    }

    /// Save the wallet keys in the secure store and refresh the in-memory cache.
    async fn save_api_wallet_keys(&self, keys: Vec<ApiWalletKey>) -> Result<()> {
        if keys.is_empty() {
            return Err(ProviderError::WalletKeyEmpty);
        }

        // Merge new keys with existing ones
        let mut merged_map: HashMap<String, ApiWalletKey> = HashMap::new();
        let mut mut_wallet_keys = self.wallet_keys.lock().await;
        if let Some(wallet_keys) = mut_wallet_keys.as_ref() {
            for key in wallet_keys {
                merged_map.insert(key.WalletID.clone(), key.clone());
            }
        }
        for key in keys.clone() {
            merged_map.insert(key.WalletID.clone(), key);
        }

        // Update the in-memory cache
        *mut_wallet_keys = Some(merged_map.values().cloned().collect());
        self.wallet_key_store.save_api_wallet_keys(keys).await?;
        Ok(())
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
pub mod mock {
    use super::*;
    use async_trait::async_trait;
    use mockall::mock;
    mock! {
        pub WalletKeysProvider {}
        #[async_trait]
        impl WalletKeysProvider for WalletKeysProvider {
            async fn get_unlocked_wallet_key(&self, wallet_id: &str) -> Result<UnlockedWalletKey>;
            async fn clear(&self);
            async fn reset(&self) -> Result<()>;
        }
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use super::*;
    use crate::{
        mocks::user_keys::tests::{
            get_test_user_3_api_wallet_key, get_test_user_3_api_wallet_key_clear,
            get_test_user_3_locked_user_key, get_test_user_3_locked_user_key_secret,
        },
        proton_wallet::{
            provider::user_keys::mock::MockUserKeysProvider,
            storage::wallet_key::mock::MockWalletKeySecureStore,
        },
    };
    use andromeda_api::{tests::wallet_mock::mock_utils::MockWalletClient, wallet::ApiWalletData};

    #[tokio::test]
    async fn test_get_unlocked_wallet_key_success() {
        let mut mock_user_keys_provider = MockUserKeysProvider::new();
        let mut mock_wallet_key_store = MockWalletKeySecureStore::new();
        let mock_wallet_client = MockWalletClient::new();

        // Mock responses for user keys and passphrase
        mock_user_keys_provider
            .expect_get_user_keys()
            .returning(|| Ok(vec![get_test_user_3_locked_user_key()]));

        mock_user_keys_provider
            .expect_get_user_key_passphrase()
            .returning(|| Ok(get_test_user_3_locked_user_key_secret()));

        // Mock response for wallet keys
        mock_wallet_key_store
            .expect_get_wallet_keys()
            .returning(|| Ok(vec![get_test_user_3_api_wallet_key()]));

        let wallet_keys_provider = WalletKeysProviderImpl::new(
            Arc::new(mock_user_keys_provider),
            Arc::new(mock_wallet_key_store),
            Arc::new(mock_wallet_client),
        );

        let result = wallet_keys_provider
            .get_unlocked_wallet_key("wallet_id_user_3")
            .await;
        assert!(result.is_ok());
        let key = result.unwrap();
        assert_eq!(key.to_entropy(), get_test_user_3_api_wallet_key_clear());
    }

    #[tokio::test]
    async fn test_clear_wallet_keys_cache() {
        let wallet_keys_provider = WalletKeysProviderImpl::new(
            Arc::new(MockUserKeysProvider::new()),
            Arc::new(MockWalletKeySecureStore::new()),
            Arc::new(MockWalletClient::new()),
        );
        wallet_keys_provider.clear().await;

        let keys = wallet_keys_provider.wallet_keys.lock().await;
        assert!(keys.is_none());
    }

    #[tokio::test]
    async fn test_get_locked_wallet_key_from_server() {
        let mut mock_wallet_client = MockWalletClient::new();
        let mut mock_wallet_key_store = MockWalletKeySecureStore::new();

        // Mock server response with wallet keys
        mock_wallet_client.expect_get_wallets().returning(|| {
            let mut mock_api_data = ApiWalletData::default();
            mock_api_data.WalletKey.WalletID = "test_wallet_id".to_string();
            Ok(vec![mock_api_data])
        });

        mock_wallet_key_store
            .expect_get_wallet_keys()
            .returning(|| Ok(vec![]));

        mock_wallet_key_store
            .expect_save_api_wallet_keys()
            .returning(|_| Ok(()));

        let wallet_keys_provider = WalletKeysProviderImpl::new(
            Arc::new(MockUserKeysProvider::new()),
            Arc::new(mock_wallet_key_store),
            Arc::new(mock_wallet_client),
        );

        let result = wallet_keys_provider
            .get_locked_wallet_key("test_wallet_id")
            .await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_get_locked_wallet_key_from_server_reset() {
        let mut mock_wallet_client = MockWalletClient::new();
        let mut mock_wallet_key_store = MockWalletKeySecureStore::new();

        // Mock server response with wallet keys
        mock_wallet_client
            .expect_get_wallets()
            .times(3)
            .returning(|| {
                let mut mock_api_data = ApiWalletData::default();
                mock_api_data.WalletKey.WalletID = "test_wallet_id".to_string();
                Ok(vec![mock_api_data])
            });

        // mock key store
        mock_wallet_key_store
            .expect_get_wallet_keys()
            .times(2)
            .returning(|| Ok(vec![get_test_user_3_api_wallet_key()]));
        mock_wallet_key_store
            .expect_save_api_wallet_keys()
            .times(3)
            .returning(|_| Ok(()));

        let wallet_keys_provider = WalletKeysProviderImpl::new(
            Arc::new(MockUserKeysProvider::new()),
            Arc::new(mock_wallet_key_store),
            Arc::new(mock_wallet_client),
        );

        let result = wallet_keys_provider
            .get_locked_wallet_key("test_wallet_id")
            .await;
        assert!(result.is_ok());
        let result = wallet_keys_provider.reset().await;
        assert!(result.is_ok());

        let result = wallet_keys_provider
            .get_locked_wallet_key("test_wallet_id")
            .await;
        assert!(result.is_ok());

        let result = wallet_keys_provider
            .get_locked_wallet_key("test_wallet_id_not_found")
            .await;
        let error = result.err().unwrap();
        assert_eq!(
            error.to_string(),
            ProviderError::WalletKeyNotFound.to_string()
        );
    }

    #[tokio::test]
    async fn test_get_locked_wallet_key_empty() {
        let mut mock_wallet_client = MockWalletClient::new();
        let mut mock_wallet_key_store = MockWalletKeySecureStore::new();

        // Mock server response with wallet keys
        mock_wallet_client
            .expect_get_wallets()
            .times(1)
            .returning(|| Ok(vec![]));

        // mock key store
        mock_wallet_key_store
            .expect_get_wallet_keys()
            .times(1)
            .returning(|| Ok(vec![]));
        mock_wallet_key_store
            .expect_save_api_wallet_keys()
            .times(0)
            .returning(|_| Ok(()));

        let wallet_keys_provider = WalletKeysProviderImpl::new(
            Arc::new(MockUserKeysProvider::new()),
            Arc::new(mock_wallet_key_store),
            Arc::new(mock_wallet_client),
        );

        let result = wallet_keys_provider
            .get_locked_wallet_key("test_wallet_id")
            .await;
        assert!(result.is_err());
        let error = result.err().unwrap();
        assert_eq!(error.to_string(), ProviderError::WalletKeyEmpty.to_string());
    }
}

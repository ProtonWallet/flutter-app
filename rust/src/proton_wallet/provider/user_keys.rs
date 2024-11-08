use async_trait::async_trait;
use std::sync::Arc;

use super::{error::ProviderError, Result};
use crate::proton_wallet::{
    db::{
        dao::proton_user_key_dao::ProtonUserKeyDao,
        model::proton_user_key_model::ProtonUserKeyModel,
    },
    storage::user_key::UserKeyStore,
};
use andromeda_api::proton_users::ProtonUsersClientExt;
use proton_crypto_account::{keys::LockedKey, salts::KeySecret};

#[async_trait]
pub trait UserKeysProvider: Send + Sync {
    /// Function to get the primary key
    async fn get_primary_key(&self) -> Result<LockedKey>;

    /// Function to get a user key by its ID
    async fn get_user_key(&self, key_id: &str) -> Result<LockedKey>;

    /// Function to get a list of user keys
    async fn get_user_keys(&self) -> Result<Vec<LockedKey>>;

    async fn get_user_key_passphrase(&self) -> Result<KeySecret>;
}

pub struct UserKeysProviderImpl {
    pub(crate) user_key_store: Arc<dyn UserKeyStore>,
    pub(crate) user_key_dao: Arc<dyn ProtonUserKeyDao>,
    pub(crate) proton_user_client: Arc<dyn ProtonUsersClientExt + Send + Sync>,
    pub(crate) user_id: String,
}

impl UserKeysProviderImpl {
    pub fn new(
        user_id: String,
        user_key_store: Arc<dyn UserKeyStore>,
        user_key_dao: Arc<dyn ProtonUserKeyDao>,
        proton_user_client: Arc<dyn ProtonUsersClientExt + Send + Sync>,
    ) -> Self {
        UserKeysProviderImpl {
            user_key_store,
            user_key_dao,
            proton_user_client,
            user_id,
        }
    }
}

#[async_trait]
impl UserKeysProvider for UserKeysProviderImpl {
    /// Function to get the primary key
    async fn get_primary_key(&self) -> Result<LockedKey> {
        let keys = self.get_user_keys().await?;
        // Find the key by ID
        if let Some(key) = keys.iter().find(|item| item.primary) {
            return Ok(key.clone());
        }

        // load from server and save to db then return
        let new_keys = self.load_user_keys_from_server().await?;
        if let Some(key) = new_keys.iter().find(|item| item.primary) {
            return Ok(key.clone());
        }

        // try to get default user key
        self.get_default_user_key().await
    }

    /// Function to get a user key by its ID
    async fn get_user_key(&self, key_id: &str) -> Result<LockedKey> {
        let keys = self.get_user_keys().await?;
        // Find the key by ID
        if let Some(key) = keys.iter().find(|item| item.id.0 == key_id) {
            return Ok(key.clone());
        }

        // load from server and save to db then return
        let new_keys = self.load_user_keys_from_server().await?;
        if let Some(key) = new_keys.iter().find(|item| item.id.0 == key_id) {
            return Ok(key.clone());
        }

        // try to get default user key
        self.get_default_user_key().await
    }

    /// get a list of user keys from the DAO by user ID
    async fn get_user_keys(&self) -> Result<Vec<LockedKey>> {
        let user_keys = self.user_key_dao.get_all_by_user_id(&self.user_id).await?;
        if user_keys.is_empty() {
            return Err(ProviderError::NoUserKeysFound);
        }
        Ok(user_keys.into_iter().map(LockedKey::from).collect())
    }

    async fn get_user_key_passphrase(&self) -> Result<KeySecret> {
        Ok(self
            .user_key_store
            .get_user_key_passphrase(self.user_id.clone())
            .await?)
    }
}
impl UserKeysProviderImpl {
    async fn load_user_keys_from_server(&self) -> Result<Vec<LockedKey>> {
        if let Some(user_keys) = self.proton_user_client.get_user_info().await?.Keys {
            let keys: Vec<ProtonUserKeyModel> = user_keys
                .into_iter()
                .map(ProtonUserKeyModel::from)
                .collect();

            // Assuming self.user_id is a String and you want to clone it
            for mut key in keys.clone() {
                // Update user_id field for each key
                key.user_id.clone_from(&self.user_id);
                self.user_key_dao.upsert(&key).await?;
            }
            return Ok(keys.into_iter().map(LockedKey::from).collect());
        }
        Err(ProviderError::NoUserKeysFound)
    }

    async fn get_default_user_key(&self) -> Result<LockedKey> {
        Ok(self
            .user_key_store
            .get_default_user_key(self.user_id.clone())
            .await?)
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
pub mod mock {
    use super::*;
    use async_trait::async_trait;
    use mockall::mock;
    mock! {
        pub UserKeysProvider {}
        #[async_trait]
        impl UserKeysProvider for UserKeysProvider {
            async fn get_primary_key(&self) -> Result<LockedKey>;
            async fn get_user_key(&self, key_id: &str) -> Result<LockedKey>;
            async fn get_user_keys(&self) -> Result<Vec<LockedKey>>;
            async fn get_user_key_passphrase(&self) -> Result<KeySecret>;
        }
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use super::*;
    use crate::{
        mocks::user_keys::tests::{
            get_test_user_2_locked_proton_user_key, get_test_user_2_locked_user_key,
            get_test_user_2_locked_user_key_secret, mock_fake_proton_user_key,
            mock_fake_proton_user_key_2, mock_fake_proton_user_key_3, TEST_USER_2_KEY,
        },
        proton_wallet::{
            db::dao::proton_user_key_dao::mock::MockProtonUserKeyDao,
            storage::{error::WalletStorageError, user_key::mock::MockUserKeySecureStore},
        },
    };
    use andromeda_api::{
        proton_users::ProtonUser, tests::proton_users_mock::mock_utils::MockProtonUsersClient,
    };

    #[tokio::test]
    async fn test_get_primary_key_success() {
        let mut mock_dao = MockProtonUserKeyDao::new();
        let mock_store = MockUserKeySecureStore::new();
        let mock_client = MockProtonUsersClient::new();

        // Mock getting keys by user ID
        mock_dao
            .expect_get_all_by_user_id()
            .with(mockall::predicate::eq("test_id"))
            .returning(move |_| Ok(vec![mock_fake_proton_user_key().into()]));

        let provider = UserKeysProviderImpl::new(
            "test_id".to_string(),
            Arc::new(mock_store),
            Arc::new(mock_dao),
            Arc::new(mock_client),
        );

        let result = provider.get_primary_key().await;
        assert!(result.is_ok());
        let primary_key = result.unwrap();
        assert_eq!(primary_key.id.to_string(), "test_id");
    }

    #[tokio::test]
    async fn test_get_primary_key_from_server() {
        let mut mock_dao = MockProtonUserKeyDao::new();
        let mut mock_client = MockProtonUsersClient::new();

        let mock_keys = vec![
            mock_fake_proton_user_key().into(),
            mock_fake_proton_user_key_2().into(),
        ];

        let mock_proton_info = ProtonUser {
            Keys: Some(vec![mock_fake_proton_user_key_3()]),
            ..Default::default()
        };

        // Mock getting keys from DAO to return empty (to force fetching from server)
        mock_dao
            .expect_get_all_by_user_id()
            .with(mockall::predicate::eq("test_id"))
            .returning(move |_| Ok(mock_keys.clone()));

        // Mock fetching user info from Proton server
        mock_client
            .expect_get_user_info()
            .returning(move || Ok(mock_proton_info.clone()));

        let provider = UserKeysProviderImpl::new(
            "test_id".to_string(),
            Arc::new(MockUserKeySecureStore::new()),
            Arc::new(mock_dao),
            Arc::new(mock_client),
        );
        let result = provider.get_primary_key().await;
        assert!(result.is_ok());
        let primary_key = result.unwrap();
        assert_eq!(primary_key.id.to_string(), "test_id");
        assert_eq!(primary_key.private_key.to_string(), "private_key");
        assert!(primary_key.primary);
    }

    #[tokio::test]
    async fn test_get_users_keys() {
        let mut mock_dao = MockProtonUserKeyDao::new();
        let mut mock_store = MockUserKeySecureStore::new();
        let mut mock_client = MockProtonUsersClient::new();

        let mock_keys = vec![
            mock_fake_proton_user_key().into(),
            mock_fake_proton_user_key_2().into(),
        ];

        let mock_proton_info = ProtonUser {
            Keys: Some(vec![get_test_user_2_locked_proton_user_key()]),
            ..Default::default()
        };

        mock_dao
            .expect_get_all_by_user_id()
            .with(mockall::predicate::eq("test_user_id"))
            .returning(move |_| Ok(mock_keys.clone()));
        mock_dao
            .expect_upsert()
            .times(2)
            .returning(|_| Ok(Some(ProtonUserKeyModel::default())));

        mock_store
            .expect_get_default_user_key()
            .with(mockall::predicate::eq("test_user_id".to_string()))
            .returning(|_| Ok(get_test_user_2_locked_user_key()));
        mock_store
            .expect_get_user_key_passphrase()
            .times(1)
            .with(mockall::predicate::eq("test_user_id".to_string()))
            .returning(|_| Ok(get_test_user_2_locked_user_key_secret()));

        mock_client
            .expect_get_user_info()
            .returning(move || Ok(mock_proton_info.clone()));

        let provider = UserKeysProviderImpl::new(
            "test_user_id".to_string(),
            Arc::new(mock_store),
            Arc::new(mock_dao),
            Arc::new(mock_client),
        );
        let result = provider.get_user_key("test_id").await;
        assert!(result.is_ok());
        let primary_key = result.unwrap();
        assert_eq!(primary_key.id.to_string(), "test_id");
        assert_eq!(primary_key.private_key.to_string(), "private_key");
        assert!(primary_key.primary);

        let result = provider.get_user_key("test_key_id").await;
        assert!(result.is_ok());
        let primary_key = result.unwrap();
        assert_eq!(primary_key.id.to_string(), "G8URRzoYaBW6mSPQjbbo2yYgwI828DVcEs8dDRKxByd1A_qSRYF49TOtw_m4wvDGb76M-r3AVdXuDzSHObR5hQ==");
        assert_eq!(primary_key.private_key.to_string(), TEST_USER_2_KEY);
        assert!(primary_key.primary);

        let primary_key = provider.get_user_key("G8URRzoYaBW6mSPQjbbo2yYgwI828DVcEs8dDRKxByd1A_qSRYF49TOtw_m4wvDGb76M-r3AVdXuDzSHObR5hQ==").await.unwrap();
        assert_eq!(primary_key.id.to_string(), "G8URRzoYaBW6mSPQjbbo2yYgwI828DVcEs8dDRKxByd1A_qSRYF49TOtw_m4wvDGb76M-r3AVdXuDzSHObR5hQ==");
        assert_eq!(primary_key.private_key.to_string(), TEST_USER_2_KEY);
        assert!(primary_key.primary);

        let passphrase = provider.get_user_key_passphrase().await;
        assert!(passphrase.is_ok());
    }

    #[tokio::test]
    async fn test_get_primary_key_not_found() {
        let mut mock_dao = MockProtonUserKeyDao::new();
        let mut mock_store = MockUserKeySecureStore::new();
        let mut mock_client = MockProtonUsersClient::new();

        mock_dao
            .expect_get_all_by_user_id()
            .with(mockall::predicate::eq("test_user"))
            .returning(move |_| Ok(vec![mock_fake_proton_user_key().into()]));

        let mock_proton_info = ProtonUser {
            Keys: None,
            ..Default::default()
        };
        mock_store
            .expect_get_default_user_key()
            .returning(|_| Err(WalletStorageError::CallbackNotSet("".to_owned())));

        mock_client
            .expect_get_user_info()
            .returning(move || Ok(mock_proton_info.clone()));
        let provider = UserKeysProviderImpl {
            user_id: "test_user".to_string(),
            user_key_dao: Arc::new(mock_dao),
            user_key_store: Arc::new(mock_store),
            proton_user_client: Arc::new(mock_client),
        };
        let result = provider.get_user_key("test_key_id").await;
        assert!(matches!(result, Err(ProviderError::NoUserKeysFound)));
    }
}

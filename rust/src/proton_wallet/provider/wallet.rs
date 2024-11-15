use andromeda_api::wallet_ext::WalletClientExt;
use async_trait::async_trait;
use std::sync::Arc;

use super::{error::ProviderError, provider::DataProvider, Result};
use crate::proton_wallet::{
    db::{
        dao::{account_dao::AccountDao, wallet_dao::WalletDao},
        model::{account_model::AccountModel, wallet_model::WalletModel},
    },
    storage::{
        wallet_mnemonic::WalletMnemonicStore,
        wallet_mnemonic_ext::{MnemonicData, WalletDatasWrap},
    },
};

/// Implementation of the WalletDataProvider interface, which interacts with wallet data
/// and performs operations like getting wallet details, mnemonic, and managing accounts.
pub struct WalletDataProviderImpl {
    pub(crate) wallet_dao: Arc<dyn WalletDao>,
    pub(crate) account_dao: Arc<dyn AccountDao>,
    pub(crate) wallet_mnemonic_store: Arc<dyn WalletMnemonicStore>,
    pub(crate) wallet_client: Arc<dyn WalletClientExt + Send + Sync>,
}

#[async_trait]
/// Trait that defines the operations related to wallet data.
pub trait WalletDataProvider: Send + Sync {
    async fn get_wallet(&self, wallet_id: &str) -> Result<WalletModel>;
    async fn get_wallet_mnemonic(&self, wallet_id: &str) -> Result<String>;
    async fn get_new_derivation_path(
        &self,
        wallet_id: &str,
        bip_version: u32,
        coin_type: u32,
    ) -> Result<String>;
}

#[async_trait]
impl WalletDataProvider for WalletDataProviderImpl {
    /// Retrieves a wallet using its `wallet_id`. Returns an error if no wallet is found.
    async fn get_wallet(&self, wallet_id: &str) -> Result<WalletModel> {
        if let Some(walle_data) = self.wallet_dao.get_by_server_id(wallet_id).await? {
            return Ok(walle_data);
        }

        // fetch from server
        self.load_from_server().await?;

        if let Some(walle_data) = self.wallet_dao.get_by_server_id(wallet_id).await? {
            return Ok(walle_data);
        }

        // throw error
        Err(ProviderError::NoWalletKeysFound)
    }

    /// Retrieves the wallet mnemonic associated with the `wallet_id`.
    async fn get_wallet_mnemonic(&self, wallet_id: &str) -> Result<String> {
        // Find the key by ID
        if let Some(mnemonic) = self.find_mnemonic_from_store(wallet_id).await? {
            return Ok(mnemonic);
        }

        // fetch from server
        self.load_from_server().await?;

        // Find the key by ID
        if let Some(mnemonic) = self.find_mnemonic_from_store(wallet_id).await? {
            return Ok(mnemonic);
        }

        Err(ProviderError::NoMnemonicFound)
    }

    /// Generates a new derivation path for the wallet based on `bip_version` and `coin_type`.
    /// It ensures no conflicts with existing derivation paths.
    async fn get_new_derivation_path(
        &self,
        wallet_id: &str,
        bip_version: u32,
        coin_type: u32,
    ) -> Result<String> {
        let mut new_account_index = 0;
        let accounts = self.account_dao.get_all_by_wallet_id(wallet_id).await?;

        // Loop to find an available derivation path, increments `account_index` until an available path is found.
        loop {
            let derivation_path =
                self.format_derivation_path(bip_version, coin_type, new_account_index);

            if self.is_derivation_path_exist(&accounts, &derivation_path)
                || self.is_derivation_path_exist(&accounts, &format!("m/{}", derivation_path))
            {
                new_account_index += 1;

                // Exit if maximum account size (10,000) is reached.
                if new_account_index > 10000 {
                    return Err(ProviderError::ReachedMaxAccountSize(10000));
                }
            } else {
                return Ok(derivation_path);
            }
        }
    }
}

impl WalletDataProviderImpl {
    async fn find_mnemonic_from_store(&self, wallet_id: &str) -> Result<Option<String>> {
        // Find the key by ID
        let wallet_mnemonics = self.wallet_mnemonic_store.get_wallet_mnemonics().await?;
        if let Some(mnemonic) = wallet_mnemonics
            .iter()
            .find(|item| item.wallet_id == wallet_id)
        {
            return Ok(mnemonic.mnemonic.clone());
        }
        Ok(None)
    }

    async fn load_from_server(&self) -> Result<()> {
        // fetch from server
        let wallets = self.wallet_client.get_wallets().await?;

        // save to local cache
        for wallet_data in wallets.clone() {
            let item: WalletModel = wallet_data.into();
            self.wallet_dao.upsert(&item).await?;
        }

        // save to mnemonic store
        let mnemonics: Vec<MnemonicData> = WalletDatasWrap(wallets).into();
        self.wallet_mnemonic_store
            .save_api_wallet_mnemonics(mnemonics)
            .await?;

        Ok(())
    }
}

impl WalletDataProviderImpl {
    /// Constructor for `WalletDataProviderImpl`, initializing required DAOs and mnemonic store.
    pub fn new(
        wallet_dao: Arc<dyn WalletDao>,
        account_dao: Arc<dyn AccountDao>,
        wallet_mnemonic_store: Arc<dyn WalletMnemonicStore>,
        wallet_client: Arc<dyn WalletClientExt + Send + Sync>,
    ) -> Self {
        WalletDataProviderImpl {
            wallet_dao,
            account_dao,
            wallet_mnemonic_store,
            wallet_client,
        }
    }

    /// Deletes a wallet by its `wallet_id`.
    pub async fn delete_by_wallet_id(&mut self, wallet_id: &str) -> Result<()> {
        self.wallet_dao.delete_by_wallet_id(wallet_id).await?;
        Ok(())
    }

    /// Retrieves all wallets associated with a specific user based on their `user_id`.
    pub async fn get_all_by_user_id(&mut self, user_id: &str) -> Result<Vec<WalletModel>> {
        Ok(self.wallet_dao.get_all_by_user_id(user_id).await?)
    }

    /// Checks if the derivation path already exists among the provided `accounts`.
    fn is_derivation_path_exist(&self, accounts: &[AccountModel], derivation_path: &str) -> bool {
        accounts
            .iter()
            .any(|account| account.derivation_path == derivation_path)
    }

    /// Formats the derivation path based on `bip_version`, `coin_type`, and `account_index`.
    fn format_derivation_path(
        &self,
        bip_version: u32,
        coin_type: u32,
        account_index: u32,
    ) -> String {
        format!("{}'/{}'/{}'", bip_version, coin_type, account_index)
    }
}

impl DataProvider<WalletModel> for WalletDataProviderImpl {
    /// Upserts (updates or inserts) a wallet in the database.
    async fn upsert(&mut self, item: WalletModel) -> Result<()> {
        self.wallet_dao.upsert(&item).await?;
        Ok(())
    }

    /// Retrieves a wallet by its server ID.
    async fn get(&mut self, server_id: &str) -> Result<Option<WalletModel>> {
        self.wallet_dao
            .get_by_server_id(server_id)
            .await
            .map_err(Into::into)
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
pub mod mock {
    use super::*;
    use async_trait::async_trait;
    use mockall::mock;
    mock! {
        pub WalletDataProvider {}
        #[async_trait]
        impl WalletDataProvider for WalletDataProvider {
            async fn get_wallet(&self, wallet_id: &str) -> Result<WalletModel>;
            async fn get_wallet_mnemonic(&self, wallet_id: &str) -> Result<String>;
            async fn get_new_derivation_path(
                &self,
                wallet_id: &str,
                bip_version: u32,
                coin_type: u32,
            ) -> Result<String>;
        }
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use super::*;
    use crate::proton_wallet::{
        db::{
            dao::{account_dao::AccountDaoImpl, wallet_dao::WalletDaoImpl},
            model::{account_model::AccountModel, wallet_model::WalletModel},
        },
        storage::wallet_mnemonic::mock::MockWalletMnemonicStore,
    };
    use andromeda_api::{tests::wallet_mock::mock_utils::MockWalletClient, wallet::ApiWalletData};
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    /// Helper function to create a WalletModel for testing
    fn build_mock_wallet(
        id: u32,
        wallet_id: &str,
        name: &str,
        public_key: &str,
        legacy: Option<u32>,
    ) -> WalletModel {
        WalletModel {
            id,
            name: name.to_string(),
            public_key: public_key.to_string(),
            user_id: "user123".to_string(),
            wallet_id: wallet_id.to_string(),
            fingerprint: Some("abc123xyz".to_string()),
            legacy,
            ..Default::default()
        }
    }

    #[tokio::test]
    async fn test_get_wallet() {
        let mut mock_mnemonic_store = MockWalletMnemonicStore::new();
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let wallet_dao = WalletDaoImpl::new(conn_arc.clone());
        let account_dao = AccountDaoImpl::new(conn_arc.clone());
        let mut mock_wallet_client = MockWalletClient::new();

        let _ = wallet_dao.database.migration_0().await;
        let _ = account_dao.database.migration_0().await;
        let _ = account_dao.database.migration_1().await;

        mock_mnemonic_store
            .expect_save_api_wallet_mnemonics()
            .returning(|_| Ok(()));

        mock_wallet_client
            .expect_get_wallets()
            .times(1)
            .returning(|| Ok(vec![ApiWalletData::default()]));

        let mut wallet_provider = WalletDataProviderImpl::new(
            Arc::new(wallet_dao.clone()),
            Arc::new(account_dao.clone()),
            Arc::new(mock_mnemonic_store),
            Arc::new(mock_wallet_client),
        );

        let wallet =
            build_mock_wallet(1, "wallet123", "MyWallet", "binary_encoded_string", Some(1));
        // Upsert the wallet into the database.
        wallet_provider.upsert(wallet.clone()).await.unwrap();
        // Test retrieving the wallet by its ID.
        let wallet_result = wallet_provider.get_wallet("wallet123").await;
        assert!(wallet_result.is_ok());

        let retrieved_wallet = wallet_result.unwrap();
        assert_eq!(retrieved_wallet.name, "MyWallet");
        assert_eq!(retrieved_wallet.public_key, "binary_encoded_string");
        assert_eq!(retrieved_wallet.fingerprint.unwrap(), "abc123xyz");

        // Test retrieving a non-existing wallet by ID.
        let non_existing_wallet_result = wallet_provider.get_wallet("non_existing_wallet").await;
        assert!(non_existing_wallet_result.is_err());
        assert_eq!(
            non_existing_wallet_result.unwrap_err().to_string(),
            ProviderError::NoWalletKeysFound.to_string()
        );
    }

    #[tokio::test]
    async fn test_get_wallet_mnemonic() {
        let mut mock_mnemonic_store = MockWalletMnemonicStore::new();
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let wallet_dao = WalletDaoImpl::new(conn_arc.clone());
        let account_dao = AccountDaoImpl::new(conn_arc.clone());

        mock_mnemonic_store
            .expect_get_wallet_mnemonics()
            .times(1)
            .returning(|| {
                Ok(vec![MnemonicData {
                    wallet_id: "wallet123".to_string(),
                    mnemonic: Some("mock_mnemonic".to_string()),
                }])
            });

        let mock_wallet_client = Arc::new(MockWalletClient::new());

        let wallet_provider = WalletDataProviderImpl::new(
            Arc::new(wallet_dao.clone()),
            Arc::new(account_dao.clone()),
            Arc::new(mock_mnemonic_store),
            mock_wallet_client,
        );
        // Test retrieving the wallet mnemonic.
        let mnemonic_result = wallet_provider
            .get_wallet_mnemonic("wallet123")
            .await
            .unwrap();
        // Expect an error, since we haven't set up any mock behavior for the mnemonic store.
        assert_eq!(mnemonic_result, "mock_mnemonic");
    }

    #[tokio::test]
    async fn test_delete_by_wallet_id() {
        let mock_mnemonic_store = MockWalletMnemonicStore::new();
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let wallet_dao = WalletDaoImpl::new(conn_arc.clone());
        let account_dao = AccountDaoImpl::new(conn_arc.clone());
        let _ = wallet_dao.database.migration_0().await;
        let _ = account_dao.database.migration_0().await;
        let _ = account_dao.database.migration_1().await;

        let mock_wallet_client = Arc::new(MockWalletClient::new());

        let mut wallet_provider = WalletDataProviderImpl::new(
            Arc::new(wallet_dao.clone()),
            Arc::new(account_dao.clone()),
            Arc::new(mock_mnemonic_store),
            mock_wallet_client,
        );

        let wallet =
            build_mock_wallet(1, "wallet123", "MyWallet", "binary_encoded_string", Some(1));

        // Upsert the wallet into the database.
        wallet_provider.upsert(wallet.clone()).await.unwrap();

        // Delete the wallet by its wallet ID.
        wallet_provider
            .delete_by_wallet_id("wallet123")
            .await
            .unwrap();

        // Try to retrieve the deleted wallet, expecting None.
        let deleted_wallet = wallet_provider.get("wallet123").await.unwrap();
        assert!(deleted_wallet.is_none());
    }

    #[tokio::test]
    async fn test_get_wallet_not_found() {
        let mock_mnemonic_store = MockWalletMnemonicStore::new();
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let wallet_dao = WalletDaoImpl::new(conn_arc.clone());
        let account_dao = AccountDaoImpl::new(conn_arc.clone());
        let _ = wallet_dao.database.migration_0().await;
        let _ = account_dao.database.migration_0().await;
        let _ = account_dao.database.migration_1().await;

        let mock_wallet_client = Arc::new(MockWalletClient::new());

        let mut wallet_provider = WalletDataProviderImpl::new(
            Arc::new(wallet_dao.clone()),
            Arc::new(account_dao.clone()),
            Arc::new(mock_mnemonic_store),
            mock_wallet_client,
        );
        // Try to retrieve a wallet that doesn't exist.
        let wallet_result = wallet_provider.get("non_existing_wallet").await;
        // Expect None since the wallet doesn't exist.
        assert!(wallet_result.unwrap().is_none());
    }

    #[tokio::test]
    async fn test_get_new_derivation_path_full_accounts() {
        let mock_mnemonic_store = MockWalletMnemonicStore::new();
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let wallet_dao = WalletDaoImpl::new(conn_arc.clone());
        let account_dao = AccountDaoImpl::new(conn_arc.clone());
        let _ = wallet_dao.database.migration_0().await;
        let _ = account_dao.database.migration_0().await;
        let _ = account_dao.database.migration_1().await;

        let mock_wallet_client = Arc::new(MockWalletClient::new());

        let mut wallet_provider = WalletDataProviderImpl::new(
            Arc::new(wallet_dao.clone()),
            Arc::new(account_dao.clone()),
            Arc::new(mock_mnemonic_store),
            mock_wallet_client,
        );

        let wallet =
            build_mock_wallet(1, "wallet123", "MyWallet", "binary_encoded_string", Some(1));

        // Upsert the wallet into the database.
        wallet_provider.upsert(wallet.clone()).await.unwrap();

        // Simulate full account usage by inserting 10,000 accounts.
        for i in 0..10_001 {
            let account_model = AccountModel {
                id: i as u32,
                account_id: format!("account{}", i),
                wallet_id: "wallet123".to_string(),
                derivation_path: format!("m/84'/0'/{}'", i),
                label: format!("My Account Label {}", i),
                script_type: 0,
                create_time: 1633072800,
                modify_time: 1633159200,
                fiat_currency: "USD".to_string(),
                priority: 10,
                last_used_index: 5,
                pool_size: 100,
            };
            account_dao.upsert(&account_model).await.unwrap();
        }

        // Try generating a new derivation path when the maximum number of accounts has been reached.
        let derivation_path_result = wallet_provider
            .get_new_derivation_path("wallet123", 84, 0)
            .await;

        // Expect an error since the maximum number of accounts is reached.
        assert!(derivation_path_result.is_err());
        assert_eq!(
            derivation_path_result.unwrap_err().to_string(),
            "Accounts full (maximum account size = 10000)"
        );
    }

    #[tokio::test]
    async fn test_wallet_provider() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        // Initialize DAOs and perform database migration for the test.
        let wallet_dao = WalletDaoImpl::new(conn_arc.clone());
        let _ = wallet_dao.database.migration_0().await;
        let account_dao = AccountDaoImpl::new(conn_arc.clone());
        let _ = account_dao.database.migration_0().await;
        let _ = account_dao.database.migration_1().await;

        // Mock wallet mnemonic store.
        let mock_mnemonic_store = MockWalletMnemonicStore::new();

        let mock_wallet_client = Arc::new(MockWalletClient::new());

        let mut wallet_provider = WalletDataProviderImpl::new(
            Arc::new(wallet_dao.clone()),
            Arc::new(account_dao.clone()),
            Arc::new(mock_mnemonic_store),
            mock_wallet_client,
        );

        // Create wallet models for testing.
        let wallet1 =
            build_mock_wallet(1, "wallet123", "MyWallet", "binary_encoded_string", Some(1));

        let wallet2 = WalletModel {
            id: 2,
            name: "MyWallet2".to_string(),
            passphrase: 0,
            public_key: "binary_encoded_string2".to_string(),
            imported: 0,
            priority: 1,
            status: 1,
            type_: 2,
            create_time: 1633072800,
            modify_time: 1633159200,
            user_id: "user123".to_string(),
            wallet_id: "wallet123456".to_string(),
            account_count: 2,
            balance: 10.2,
            fingerprint: Some("abc456xyz".to_string()),
            show_wallet_recovery: 1,
            migration_required: 0,
            legacy: Some(0),
        };

        // Upsert the wallets into the database.
        wallet_provider.upsert(wallet1.clone()).await.unwrap();
        wallet_provider.upsert(wallet2.clone()).await.unwrap();

        // Test getting wallets by user ID.
        let wallets = wallet_provider.get_all_by_user_id("user123").await.unwrap();
        assert_eq!(wallets.len(), 2);

        // Test retrieving the first wallet by its wallet ID.
        let wallet = wallet_provider.get("wallet123").await.unwrap().unwrap();
        assert_eq!(wallet.name, "MyWallet");
        assert_eq!(wallet.public_key, "binary_encoded_string");
        assert_eq!(wallet.fingerprint.unwrap(), "abc123xyz");

        // Test retrieving the second wallet by its wallet ID.
        let wallet = wallet_provider.get("wallet123456").await.unwrap().unwrap();
        assert_eq!(wallet.name, "MyWallet2");
        assert_eq!(wallet.public_key, "binary_encoded_string2");
        assert_eq!(wallet.fingerprint.unwrap(), "abc456xyz");

        // Test wallet deletion.
        wallet_provider
            .delete_by_wallet_id("wallet123456")
            .await
            .unwrap();
        let wallets = wallet_provider.get_all_by_user_id("user123").await.unwrap();
        assert_eq!(wallets.len(), 1); // Only one wallet should remain.

        let wallets = wallet_provider
            .get_all_by_user_id("user123111")
            .await
            .unwrap();
        assert_eq!(wallets.len(), 0); // Only one wallet should remain.

        // Test updating the wallet's name and upserting it again.
        let mut wallet = wallet_provider.get("wallet123").await.unwrap().unwrap();
        wallet.name = "New Name".to_string();
        wallet_provider.upsert(wallet.clone()).await.unwrap();

        // Verify the wallet's name has been updated.
        let updated_wallet = wallet_provider.get("wallet123").await.unwrap().unwrap();
        assert_eq!(updated_wallet.name, "New Name");

        // Test generating a new derivation path.
        let derivation_path = wallet_provider
            .get_new_derivation_path("wallet123", 84, 0)
            .await
            .unwrap();
        assert_eq!(derivation_path, "84'/0'/0'");

        // Insert accounts to test derivation path generation.
        let account_model1 = AccountModel {
            id: 1,
            account_id: "account1".to_string(),
            wallet_id: "wallet123".to_string(),
            derivation_path: "m/84'/0'/0'".to_string(),
            label: "My Account Label 1".to_string(),
            script_type: 0,
            create_time: 1633072800,
            modify_time: 1633159200,
            fiat_currency: "USD".to_string(),
            priority: 10,
            last_used_index: 5,
            pool_size: 100,
        };

        let account_model2 = AccountModel {
            id: 2,
            account_id: "account2".to_string(),
            wallet_id: "wallet123".to_string(),
            derivation_path: "m/84'/0'/1'".to_string(),
            label: "My Account Label 2".to_string(),
            script_type: 0,
            create_time: 1633072800,
            modify_time: 1633159200,
            fiat_currency: "MMR".to_string(),
            priority: 11,
            last_used_index: 0,
            pool_size: 100,
        };

        // Insert accounts into the database.
        account_dao.upsert(&account_model1).await.unwrap();
        account_dao.upsert(&account_model2).await.unwrap();

        // Test generating the next available derivation path.
        let derivation_path = wallet_provider
            .get_new_derivation_path("wallet123", 84, 0)
            .await
            .unwrap();
        assert_eq!(derivation_path, "84'/0'/2'");
    }
}

use flutter_rust_bridge::frb;
use tracing::info;

use crate::{
    proton_wallet::db::{
        app_database::AppDatabase,
        dao::{account_dao::AccountDao, wallet_dao::WalletDao},
        model::{account_model::AccountModel, wallet_model::WalletModel},
    },
    BridgeError,
};

#[derive(Debug)]
pub struct FrbAppDatabase {
    pub(crate) inner: AppDatabase,
}

impl FrbAppDatabase {
    #[frb(sync)]
    pub fn new(database_url: &str) -> Result<FrbAppDatabase, BridgeError> {
        let app_database = AppDatabase::new(database_url);
        Ok(FrbAppDatabase {
            inner: app_database,
        })
    }

    /// Expose functions in appDatabase
    pub async fn build_database(&mut self, old_version: u32) -> Result<(), BridgeError> {
        info!("Start build database in Rust ˊ_>ˋ");
        let _ = self.inner.init().await;
        Ok(self.inner.build_database(old_version).await?)
    }

    /// Expose functions in walletDao
    /// We can remove these functions once we migrate the function call from Dart data provider
    /// to Rust data provider

    pub async fn get_wallet_by_wallet_id(
        &self,
        wallet_id: &str,
    ) -> Result<Option<WalletModel>, BridgeError> {
        let wallet_dao = &self.inner.wallet_dao;
        Ok(wallet_dao.get_by_server_id(wallet_id).await?)
    }

    pub async fn get_default_wallet_by_user_id(
        &self,
        user_id: &str,
    ) -> Result<Option<WalletModel>, BridgeError> {
        let wallet_dao = &self.inner.wallet_dao;
        Ok(wallet_dao.get_default_wallet_by_user_id(user_id).await?)
    }

    pub async fn upsert_wallet(
        &self,
        wallet: WalletModel,
    ) -> Result<Option<WalletModel>, BridgeError> {
        let wallet_dao = &self.inner.wallet_dao;
        Ok(wallet_dao.upsert(&wallet).await?)
    }

    pub async fn get_all_wallets(&self) -> Result<Vec<WalletModel>, BridgeError> {
        let wallet_dao = &self.inner.wallet_dao;
        Ok(wallet_dao.get_all().await?)
    }

    pub async fn get_all_wallets_by_user_id(
        &self,
        user_id: &str,
    ) -> Result<Vec<WalletModel>, BridgeError> {
        let wallet_dao = &self.inner.wallet_dao;
        Ok(wallet_dao.get_all_by_user_id(user_id).await?)
    }

    pub async fn delete_wallet(&self, wallet_id: &str) -> Result<(), BridgeError> {
        let wallet_dao = &self.inner.wallet_dao;
        Ok(wallet_dao.delete_by_wallet_id(wallet_id).await?)
    }

    /// Expose functions in accountDao
    /// We can remove these functions once we migrate the function call from Dart data provider
    /// to Rust data provider
    pub async fn get_wallet_account_by_account_id(
        &self,
        account_id: &str,
    ) -> Result<Option<AccountModel>, BridgeError> {
        let account_dao = &self.inner.account_dao;
        Ok(account_dao.get_by_server_id(account_id).await?)
    }

    pub async fn get_all_wallet_accounts(&self) -> Result<Vec<AccountModel>, BridgeError> {
        let account_dao = &self.inner.account_dao;
        Ok(account_dao.get_all().await?)
    }

    pub async fn get_all_wallet_accounts_by_wallet_id(
        &self,
        wallet_id: &str,
    ) -> Result<Vec<AccountModel>, BridgeError> {
        let account_dao = &self.inner.account_dao;
        Ok(account_dao.get_all_by_wallet_id(wallet_id).await?)
    }

    pub async fn upsert_wallet_account(
        &self,
        account: AccountModel,
    ) -> Result<Option<AccountModel>, BridgeError> {
        let account_dao = &self.inner.account_dao;
        Ok(account_dao.upsert(&account).await?)
    }

    pub async fn delete_wallet_account(&self, account_id: &str) -> Result<(), BridgeError> {
        let account_dao = &self.inner.account_dao;
        Ok(account_dao.delete_by_account_id(account_id).await?)
    }
}

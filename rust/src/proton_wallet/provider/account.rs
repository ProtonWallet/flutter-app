use super::{provider::DataProvider, Result};
use crate::proton_wallet::db::{
    dao::account_dao::{AccountDao, AccountDaoImpl},
    model::account_model::AccountModel,
};

pub struct AccountDataProvider {
    dao: AccountDaoImpl,
}

impl AccountDataProvider {
    pub fn new(dao: AccountDaoImpl) -> Self {
        AccountDataProvider { dao }
    }

    pub async fn delete_by_wallet_id(&mut self, wallet_id: &str) -> Result<()> {
        let result = self.dao.delete_by_wallet_id(wallet_id).await;
        result?;

        Ok(())
    }

    pub async fn delete_by_account_id(&mut self, account_id: &str) -> Result<()> {
        let result = self.dao.delete_by_account_id(account_id).await;
        result?;

        Ok(())
    }

    pub async fn get_all_by_wallet_id(&mut self, wallet_id: &str) -> Result<Vec<AccountModel>> {
        Ok(self.dao.get_all_by_wallet_id(wallet_id).await?)
    }
}

impl DataProvider<AccountModel> for AccountDataProvider {
    async fn upsert(&mut self, item: AccountModel) -> Result<()> {
        let result = self.dao.upsert(&item).await;
        result?;

        Ok(())
    }

    async fn get(&mut self, server_id: &str) -> Result<Option<AccountModel>> {
        Ok(self.dao.get_by_server_id(server_id).await?)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_account_provider() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let account_dao = AccountDaoImpl::new(conn_arc.clone());
        let _ = account_dao.database.migration_0().await;
        let _ = account_dao.database.migration_1().await;
        let mut account_provider = AccountDataProvider::new(account_dao);

        let account1 = AccountModel {
            id: 1,
            account_id: "test_account_id".to_string(),
            wallet_id: "test_wallet_id".to_string(),
            derivation_path: "m/44'/0'/0'/0".to_string(),
            label: "My Account Label".to_string(),
            script_type: 0,
            create_time: 1633072800,
            modify_time: 1633159200,
            fiat_currency: "USD".to_string(),
            priority: 10,
            last_used_index: 5,
            pool_size: 100,
        };
        let account2 = AccountModel {
            id: 2,
            account_id: "test_account_id_2".to_string(),
            wallet_id: "test_wallet_id_2".to_string(),
            derivation_path: "m/44'/0'/1'/0".to_string(),
            label: "My Account Label 2".to_string(),
            script_type: 0,
            create_time: 1633072800,
            modify_time: 1633159200,
            fiat_currency: "MMR".to_string(),
            priority: 11,
            last_used_index: 0,
            pool_size: 100,
        };
        let account3 = AccountModel {
            id: 3,
            account_id: "test_account_id_3".to_string(),
            wallet_id: "test_wallet_id_3".to_string(),
            derivation_path: "m/44'/0'/0'/0".to_string(),
            label: "My Account Label 3".to_string(),
            script_type: 0,
            create_time: 1633072800,
            modify_time: 1633159200,
            fiat_currency: "TWD".to_string(),
            priority: 1,
            last_used_index: 0,
            pool_size: 100,
        };
        let _ = account_provider.upsert(account1.clone()).await;
        let _ = account_provider.upsert(account2.clone()).await;
        let _ = account_provider.upsert(account3.clone()).await;

        // Test get_all_by_wallet_id
        let wallet_id = "test_wallet_id";
        let accounts = account_provider
            .get_all_by_wallet_id(wallet_id)
            .await
            .unwrap();
        assert_eq!(accounts.len(), 1);
        assert_eq!(accounts[0].account_id, account1.account_id);

        // Test get
        let account = account_provider.get("test_account_id_2").await.unwrap();
        assert!(account.is_some());
        assert_eq!(account.unwrap().account_id, account2.account_id);

        // Test delete_by_wallet_id
        let _ = account_provider
            .delete_by_wallet_id("test_wallet_id_3")
            .await;
        let accounts_after_delete = account_provider
            .get_all_by_wallet_id("test_wallet_id_3")
            .await
            .unwrap();
        assert!(accounts_after_delete.is_empty());

        // Test delete_by_account_id
        let _ = account_provider
            .delete_by_account_id("test_account_id_2")
            .await;
        let account_after_delete = account_provider.get("test_account_id_2").await.unwrap();
        assert!(account_after_delete.is_none());
    }
}

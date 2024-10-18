use super::{provider::DataProvider, Result};
use crate::proton_wallet::db::{dao::address_dao::AddressDao, model::address_model::AddressModel};

///
/// AddressDataProvider handle wallet account BvE settings
/// one wallet account can only linked to one address
///
pub struct AddressDataProvider {
    dao: AddressDao,
}

impl AddressDataProvider {
    pub fn new(dao: AddressDao) -> Self {
        AddressDataProvider { dao }
    }

    pub async fn get_all(&mut self) -> Result<Vec<AddressModel>> {
        Ok(self.dao.get_all().await?)
    }

    pub async fn get_all_by_account_id(&mut self, account_id: &str) -> Result<Vec<AddressModel>> {
        Ok(self.dao.get_all_by_account_id(account_id).await?)
    }

    pub async fn delete_by_server_id(&mut self, server_id: &str) -> Result<()> {
        let result = self.dao.delete_by_server_id(server_id).await;
        result?;

        Ok(())
    }

    pub async fn delete_by_account_id(&mut self, account_id: &str) -> Result<()> {
        let result = self.dao.delete_by_account_id(account_id).await;
        result?;

        Ok(())
    }
}

impl DataProvider<AddressModel> for AddressDataProvider {
    async fn upsert(&mut self, item: AddressModel) -> Result<()> {
        let result = self.dao.upsert(&item).await;
        result?;

        Ok(())
    }

    async fn get(&mut self, server_id: &str) -> Result<Option<AddressModel>> {
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
    async fn test_address_provider() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let address_dao = AddressDao::new(conn_arc.clone());
        let _ = address_dao.database.migration_0().await;
        let mut address_provider = AddressDataProvider::new(address_dao);

        let address1 = AddressModel {
            id: 1,
            server_id: "server1".to_string(),
            email: "user@example.com".to_string(),
            server_wallet_id: "wallet123".to_string(),
            server_account_id: "account1".to_string(),
        };

        let mut address2 = address1.clone();
        address2.server_id = "server2".to_string();
        address2.email = "test@proton.me".to_string();

        let mut address3 = address1.clone();
        address3.server_id = "server3".to_string();
        address3.email = "test3@proton.me".to_string();
        address3.server_account_id = "account2".to_string();

        let _ = address_provider.upsert(address1.clone()).await;
        let _ = address_provider.upsert(address2.clone()).await;
        let _ = address_provider.upsert(address3.clone()).await;

        // Test get_all
        let all_addresses = address_provider.get_all().await.unwrap();
        assert_eq!(all_addresses.len(), 3);

        // Test get_all_by_account_id
        let account1_addresses = address_provider
            .get_all_by_account_id("account1")
            .await
            .unwrap();
        assert_eq!(account1_addresses.len(), 2);
        let account2_addresses = address_provider
            .get_all_by_account_id("account2")
            .await
            .unwrap();
        assert_eq!(account2_addresses.len(), 1);

        // Test get by server_id
        let get_address1 = address_provider.get("server1").await.unwrap();
        assert!(get_address1.is_some());
        assert_eq!(get_address1.unwrap().email, "user@example.com");

        let get_address2 = address_provider.get("server2").await.unwrap();
        assert!(get_address2.is_some());
        assert_eq!(get_address2.unwrap().email, "test@proton.me");

        // Test delete_by_server_id
        let _ = address_provider.delete_by_server_id("server1").await;
        let get_deleted_address1 = address_provider.get("server1").await.unwrap();
        assert!(get_deleted_address1.is_none());

        // Test delete_by_account_id
        let _ = address_provider.delete_by_account_id("account2").await;
        let account2_addresses_after_delete = address_provider
            .get_all_by_account_id("account2")
            .await
            .unwrap();
        assert_eq!(account2_addresses_after_delete.len(), 0);
    }
}

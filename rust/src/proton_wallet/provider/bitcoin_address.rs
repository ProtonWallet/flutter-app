use super::{provider::DataProvider, Result};
use crate::proton_wallet::db::{
    dao::bitcoin_address_dao::BitcoinAddressDao, model::bitcoin_address_model::BitcoinAddressModel,
};

pub struct BitcoinAddressDataProvider {
    dao: BitcoinAddressDao,
}

impl BitcoinAddressDataProvider {
    pub fn new(dao: BitcoinAddressDao) -> Self {
        BitcoinAddressDataProvider { dao }
    }

    pub async fn get_all(&mut self) -> Result<Vec<BitcoinAddressModel>> {
        Ok(self.dao.get_all().await?)
    }

    pub async fn get_all_by_account_id(
        &mut self,
        account_id: &str,
    ) -> Result<Vec<BitcoinAddressModel>> {
        Ok(self.dao.get_all_by_account_id(account_id).await?)
    }
}

impl DataProvider<BitcoinAddressModel> for BitcoinAddressDataProvider {
    async fn upsert(&mut self, item: BitcoinAddressModel) -> Result<()> {
        let result = self.dao.upsert(&item).await;
        result?;

        Ok(())
    }

    async fn get(&mut self, server_id: &str) -> Result<Option<BitcoinAddressModel>> {
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
    async fn test_bitcoin_address_provider() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let bitcoin_address_dao = BitcoinAddressDao::new(conn_arc.clone());
        let _ = bitcoin_address_dao.database.migration_0().await;
        let mut bitcoin_address_provider = BitcoinAddressDataProvider::new(bitcoin_address_dao);

        let bitcoin_address1 = BitcoinAddressModel {
            id: Some(1),
            server_id: "serverid_1".to_string(),
            wallet_id: 100,
            account_id: 200,
            bitcoin_address: "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa".to_string(),
            bitcoin_address_index: 0,
            in_email_integration_pool: 1,
            used: 0,
            server_wallet_id: "server_wallet_123".to_string(),
            server_account_id: "server_account_456".to_string(),
        };

        let mut bitcoin_address2 = bitcoin_address1.clone();
        bitcoin_address2.server_id = "serverid_2".to_string();
        bitcoin_address2.bitcoin_address = "BC3YGWIQK314JOJPDFs2QWIUdd15HIchSHUIU".to_string();
        bitcoin_address2.bitcoin_address_index = 11;
        bitcoin_address2.in_email_integration_pool = 0;
        bitcoin_address2.server_account_id = "server_account_777".to_string();
        bitcoin_address2.used = 1;

        let _ = bitcoin_address_provider
            .upsert(bitcoin_address1.clone())
            .await;
        let _ = bitcoin_address_provider
            .upsert(bitcoin_address2.clone())
            .await;

        // Test get
        let fetched_bitcoin_address1 = bitcoin_address_provider
            .get("serverid_1")
            .await
            .expect("Failed to get bitcoin address")
            .expect("Bitcoin address not found");
        assert_eq!(
            fetched_bitcoin_address1.server_id,
            bitcoin_address1.server_id
        );

        // Test get_all
        let all_bitcoin_addresss = bitcoin_address_provider
            .get_all()
            .await
            .expect("Failed to get all bitcoin addresses");
        assert_eq!(all_bitcoin_addresss.len(), 2);
        assert_eq!(
            all_bitcoin_addresss[0].server_id,
            bitcoin_address1.server_id
        );
        assert_eq!(
            all_bitcoin_addresss[1].server_id,
            bitcoin_address2.server_id
        );

        let all_bitcoin_addresss = bitcoin_address_provider
            .get_all_by_account_id("server_account_456")
            .await
            .expect("Failed to get all bitcoin addresses");
        assert_eq!(all_bitcoin_addresss.len(), 1);
        assert_eq!(
            all_bitcoin_addresss[0].server_id,
            bitcoin_address1.server_id
        );
    }
}

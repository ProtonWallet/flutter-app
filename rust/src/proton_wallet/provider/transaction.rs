use super::{provider::DataProvider, Result};
use crate::proton_wallet::db::{
    dao::transaction_dao::TransactionDao, model::transaction_model::TransactionModel,
};

pub struct TransactionDataProvider {
    dao: TransactionDao,
}

impl TransactionDataProvider {
    pub fn new(dao: TransactionDao) -> Self {
        TransactionDataProvider { dao }
    }

    pub async fn delete_by_server_id(&mut self, server_id: &str) -> Result<()> {
        let result = self.dao.delete_by_server_id(server_id).await;
        result?;

        Ok(())
    }

    pub async fn get_by_account_id(&mut self, account_id: &str) -> Result<Vec<TransactionModel>> {
        Ok(self.dao.get_by_account_id(account_id).await?)
    }
}

impl DataProvider<TransactionModel> for TransactionDataProvider {
    async fn upsert(&mut self, item: TransactionModel) -> Result<()> {
        let result = self.dao.upsert(&item).await;
        result?;
        Ok(())
    }

    async fn get(&mut self, server_id: &str) -> Result<Option<TransactionModel>> {
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
    async fn test_transaction_provider() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let transaction_dao = TransactionDao::new(conn_arc.clone());
        let _ = transaction_dao.database.migration_0().await;
        let mut transaction_provider = TransactionDataProvider::new(transaction_dao);

        let transaction1 = TransactionModel {
            id: 1,
            type_: 1,
            label: "binary_encoded_label".to_string(),
            external_transaction_id: "external_transaction_id".to_string(),
            create_time: 1633072800,
            modify_time: 1633159200,
            hashed_transaction_id: "hashed_transaction_id".to_string(),
            transaction_id: "txn123".to_string(),
            transaction_time: "2024-09-18T12:00:00Z".to_string(),
            exchange_rate_id: "rate123".to_string(),
            server_wallet_id: "wallet123".to_string(),
            server_account_id: "account123".to_string(),
            server_id: "server123".to_string(),
            sender: Some("sender@example.com".to_string()),
            tolist: Some("recipient@example.com".to_string()),
            subject: Some("Transaction Subject".to_string()),
            body: Some("Transaction Body".to_string()),
            is_suspicious: 0,
            is_private: 0,
            is_anonymous: Some(1),
        };

        let mut transaction2 = transaction1.clone();
        transaction2.id = 2;
        transaction2.server_id = "id99999".to_string();
        transaction2.label = "helllllllo world".to_string();
        transaction2.subject = None;
        transaction2.body = None;
        transaction2.create_time = 199999992;
        transaction2.modify_time = 199999999;

        let _ = transaction_provider.upsert(transaction1.clone()).await;
        let _ = transaction_provider.upsert(transaction2.clone()).await;

        // Test get_all
        let transactions = transaction_provider
            .get_by_account_id("account123")
            .await
            .unwrap();
        assert_eq!(transactions.len(), 2);
        assert_eq!(
            transactions[0].server_account_id,
            transaction1.server_account_id
        );
        assert_eq!(transactions[0].create_time, transaction1.create_time);
        assert_eq!(
            transactions[0].hashed_transaction_id,
            transaction1.hashed_transaction_id
        );
        assert_eq!(transactions[0].label, transaction1.label);

        assert_eq!(
            transactions[1].server_account_id,
            transaction2.server_account_id
        );
        assert_eq!(transactions[1].create_time, transaction2.create_time);
        assert_eq!(
            transactions[1].hashed_transaction_id,
            transaction2.hashed_transaction_id
        );
        assert_eq!(transactions[1].label, transaction2.label);

        // Test get
        let transaction = transaction_provider.get("server123").await.unwrap();
        assert!(transaction.is_some());
        let transaction = transaction.unwrap();
        assert_eq!(
            transaction.hashed_transaction_id,
            transaction1.hashed_transaction_id
        );
        assert_eq!(
            transaction.server_account_id,
            transaction1.server_account_id
        );
        assert_eq!(transaction.label, transaction1.label);

        // Test delete

        let _ = transaction_provider.delete_by_server_id("server123").await;
        let transaction = transaction_provider.get("server123").await.unwrap();
        assert!(transaction.is_none());

        let transactions = transaction_provider
            .get_by_account_id("account123")
            .await
            .unwrap();
        assert_eq!(transactions.len(), 1);
    }
}

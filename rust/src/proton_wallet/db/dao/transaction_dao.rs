use log::error;
use rusqlite::{params, Connection};
use std::sync::Arc;
use tokio::sync::Mutex;

use super::Result;
use crate::proton_wallet::db::{
    database::{database::BaseDatabase, transaction::TransactionDatabase},
    error::DatabaseError,
    model::transaction_model::TransactionModel,
};

#[derive(Debug)]
pub struct TransactionDao {
    conn: Arc<Mutex<Connection>>,
    pub database: TransactionDatabase,
}

impl TransactionDao {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        let database = TransactionDatabase::new(conn.clone());
        Self { conn, database }
    }
}

impl TransactionDao {
    pub async fn upsert(&self, item: &TransactionModel) -> Result<Option<TransactionModel>> {
        if (self.get_by_server_id(&item.server_id).await?).is_some() {
            self.update(item).await?;
        } else {
            self.insert(item).await?;
        }
        self.get_by_server_id(&item.server_id).await
    }

    pub async fn insert(&self, item: &TransactionModel) -> Result<u32> {
        let conn = self.conn.lock().await;
        let result: std::result::Result<usize, rusqlite::Error> = conn.execute(
            "INSERT INTO transaction_table (type, label, external_transaction_id, create_time, modify_time, hashed_transaction_id, transaction_id, transaction_time, exchange_rate_id, server_wallet_id, server_account_id, server_id, sender, tolist, subject, body) 
            VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16)",
            params![
                item.type_,
                item.label,
                item.external_transaction_id,
                item.create_time,
                item.modify_time,
                item.hashed_transaction_id,
                item.transaction_id,
                item.transaction_time,
                item.exchange_rate_id,
                item.server_wallet_id,
                item.server_account_id,
                item.server_id,
                item.sender,
                item.tolist,
                item.subject,
                item.body
            ]
        );
        match result {
            Ok(_) => Ok(conn.last_insert_rowid() as u32),
            Err(e) => {
                error!("Something went wrong: {}", e);
                Err(e.into())
            }
        }
    }

    pub async fn update(&self, item: &TransactionModel) -> Result<Option<TransactionModel>> {
        let conn = self.conn.lock().await;
        let rows_affected = conn.execute(
            "UPDATE transaction_table SET type = ?1, label = ?2, external_transaction_id = ?3, create_time = ?4, modify_time = ?5, hashed_transaction_id = ?6, transaction_id = ?7, transaction_time = ?8, exchange_rate_id = ?9, server_wallet_id = ?10, server_account_id = ?11, server_id = ?12, sender = ?13, tolist = ?14, subject = ?15, body = ?16 WHERE id = ?17",
            params![
                item.type_,
                item.label,
                item.external_transaction_id,
                item.create_time,
                item.modify_time,
                item.hashed_transaction_id,
                item.transaction_id,
                item.transaction_time,
                item.exchange_rate_id,
                item.server_wallet_id,
                item.server_account_id,
                item.server_id,
                item.sender,
                item.tolist,
                item.subject,
                item.body,
                item.id
            ]
        )?;

        if rows_affected == 0 {
            return Err(DatabaseError::NoChangedRows);
        }

        std::mem::drop(conn); // release connection before we want to use self.get()
        self.get(item.id).await
    }

    pub async fn get(&self, id: u32) -> Result<Option<TransactionModel>> {
        self.database.get_by_id(id).await
    }

    pub async fn get_by_server_id(&self, server_id: &str) -> Result<Option<TransactionModel>> {
        self.database.get_by_column_id("server_id", server_id).await
    }

    pub async fn get_by_account_id(&self, account_id: &str) -> Result<Vec<TransactionModel>> {
        self.database
            .get_all_by_column_id("server_account_id", account_id)
            .await
    }

    pub async fn get_all(&self) -> Result<Vec<TransactionModel>> {
        self.database.get_all().await
    }

    pub async fn delete_by_server_id(&self, server_id: &str) -> Result<()> {
        self.database
            .delete_by_column_id("server_id", server_id)
            .await
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::dao::transaction_dao::TransactionDao;
    use crate::proton_wallet::db::model::transaction_model::TransactionModel;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_transaction_dao() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        {
            // create table
            let conn_arc_cp = Arc::clone(&conn_arc);
            let conn = conn_arc_cp.lock().await;
            let _ = conn.execute(
                r#"
                CREATE TABLE IF NOT EXISTS transaction_table (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    type INTEGER NOT NULL,
                    label TEXT NOT NULL,
                    external_transaction_id TEXT NOT NULL,
                    create_time INTEGER NOT NULL,
                    modify_time INTEGER NOT NULL,
                    hashed_transaction_id TEXT NOT NULL,
                    transaction_id TEXT NOT NULL,
                    transaction_time TEXT NOT NULL,
                    exchange_rate_id TEXT NOT NULL,
                    server_wallet_id TEXT NOT NULL,
                    server_account_id TEXT NOT NULL,
                    server_id TEXT NOT NULL,
                    sender TEXT,
                    tolist TEXT,
                    subject TEXT,
                    body TEXT
                )
                "#,
                [],
            );
        }
        let transaction_dao = TransactionDao::new(conn_arc);
        let transactions = transaction_dao.get_all().await.unwrap();
        assert_eq!(transactions.len(), 0);

        let transaction = TransactionModel {
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
        };

        let mut transaction2 = transaction.clone();
        transaction2.id = 2;
        transaction2.server_id = "id99999".to_string();
        transaction2.label = "helllllllo world".to_string();
        transaction2.subject = None;
        transaction2.body = None;
        transaction2.server_account_id = "new_acc".to_string();
        transaction2.create_time = 199999992;
        transaction2.modify_time = 199999999;

        // test insert
        let upsert_result = transaction_dao.upsert(&transaction).await.unwrap().unwrap();
        assert_eq!(upsert_result.id, 1);

        let upsert_result = transaction_dao
            .upsert(&transaction2)
            .await
            .unwrap()
            .unwrap();
        assert_eq!(upsert_result.id, 2);

        // test query
        let query_item = transaction_dao.get(1).await.unwrap().unwrap();
        assert_eq!(query_item.exchange_rate_id, "rate123");
        assert_eq!(query_item.server_wallet_id, "wallet123");
        assert_eq!(query_item.label, "binary_encoded_label");
        assert_eq!(query_item.server_account_id, "account123");
        assert_eq!(query_item.modify_time, 1633159200);
        assert_eq!(query_item.tolist, Some("recipient@example.com".to_string()));
        assert!(query_item.subject.is_some());

        let query_item = transaction_dao.get(2).await.unwrap().unwrap();
        assert_eq!(query_item.exchange_rate_id, "rate123");
        assert_eq!(query_item.server_wallet_id, "wallet123");
        assert_eq!(query_item.label, "helllllllo world");
        assert_eq!(query_item.server_account_id, "new_acc");
        assert_eq!(query_item.modify_time, 199999999);
        assert_eq!(query_item.tolist, Some("recipient@example.com".to_string()));
        assert!(query_item.subject.is_none());

        let transactions = transaction_dao.get_all().await.unwrap();
        assert_eq!(transactions.len(), 2);

        let transactions = transaction_dao
            .get_by_account_id("account123")
            .await
            .unwrap();
        assert_eq!(transactions.len(), 1);
        let transactions = transaction_dao.get_by_account_id("new_acc").await.unwrap();
        assert_eq!(transactions.len(), 1);
        let transactions = transaction_dao
            .get_by_account_id("account1234")
            .await
            .unwrap();
        assert_eq!(transactions.len(), 0);

        let _ = transaction_dao.delete_by_server_id("server12345").await;

        let contacts = transaction_dao.get_all().await.unwrap();
        assert_eq!(contacts.len(), 2);

        let _ = transaction_dao.delete_by_server_id("server123").await;

        let contacts = transaction_dao.get_all().await.unwrap();
        assert_eq!(contacts.len(), 1);

        // test update
        let mut query_item = transaction_dao.get(2).await.unwrap().unwrap();
        query_item.label = "new label here".to_string();
        query_item.create_time = 666666666;
        query_item.modify_time = 777777777;
        let upsert_result = transaction_dao.upsert(&query_item).await.unwrap().unwrap();
        assert_eq!(upsert_result.id, 2);

        let query_item = transaction_dao
            .get_by_server_id(&query_item.server_id)
            .await
            .unwrap()
            .unwrap();
        assert_eq!(query_item.exchange_rate_id, "rate123");
        assert_eq!(query_item.server_wallet_id, "wallet123");
        assert_eq!(query_item.label, "new label here");
        assert_eq!(query_item.server_account_id, "new_acc");
        assert_eq!(query_item.create_time, 666666666);
        assert_eq!(query_item.modify_time, 777777777);
        assert_eq!(query_item.tolist, Some("recipient@example.com".to_string()));
        assert!(query_item.subject.is_none());
    }
}

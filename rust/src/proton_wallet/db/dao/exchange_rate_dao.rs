use crate::proton_wallet::db::database::error::DatabaseError;
use crate::proton_wallet::db::database::{
    database::BaseDatabase, exchange_rate::ExchangeRateDatabase,
};
use crate::proton_wallet::db::model::exchange_rate_model::ExchangeRateModel;
use rusqlite::{params, Connection, Result};
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Debug)]
pub struct ExchangeRateDao {
    conn: Arc<Mutex<Connection>>,
    pub database: ExchangeRateDatabase,
}

impl ExchangeRateDao {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        let database = ExchangeRateDatabase::new(conn.clone());
        Self { conn, database }
    }
}

impl ExchangeRateDao {
    pub async fn upsert(
        &self,
        item: &ExchangeRateModel,
    ) -> Result<Option<ExchangeRateModel>, DatabaseError> {
        if let Some(_) = self.get_by_server_id(&item.server_id).await? {
            self.update(item).await?;
        } else {
            self.insert(item).await?;
        }
        self.get_by_server_id(&item.server_id).await
    }

    pub async fn insert(&self, item: &ExchangeRateModel) -> Result<u32> {
        let conn = self.conn.lock().await;
        let result: std::result::Result<usize, rusqlite::Error> = conn.execute(
            "INSERT INTO exchange_rate_table (server_id, bitcoin_unit, fiat_currency, sign, exchange_rate_time, exchange_rate, cents) 
            VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
            params![
                item.server_id,
                item.bitcoin_unit,
                item.fiat_currency,
                item.sign,
                item.exchange_rate_time,
                item.exchange_rate,
                item.cents
            ]
        );

        match result {
            Ok(_) => Ok(conn.last_insert_rowid() as u32),
            Err(e) => {
                eprintln!("Something went wrong: {}", e);
                Err(e)
            }
        }
    }

    pub async fn update(&self, item: &ExchangeRateModel) -> Result<Option<ExchangeRateModel>> {
        let conn = self.conn.lock().await;
        let rows_affected = conn.execute(
            "UPDATE exchange_rate_table SET server_id = ?1, bitcoin_unit = ?2, fiat_currency = ?3, sign = ?4, exchange_rate_time = ?5, exchange_rate = ?6, cents = ?7 WHERE id = ?8",
            params![
                item.server_id,
                item.bitcoin_unit,
                item.fiat_currency,
                item.sign,
                item.exchange_rate_time,
                item.exchange_rate,
                item.cents,
                item.id.unwrap_or_default()
            ]
        )?;

        if rows_affected == 0 {
            return Err(rusqlite::Error::StatementChangedRows(0));
        }

        std::mem::drop(conn); // release connection before we want to use self.get()
        Ok(self.get(item.id.unwrap_or_default()).await?)
    }

    pub async fn get(&self, id: u32) -> Result<Option<ExchangeRateModel>> {
        self.database.get_by_id(id).await
    }

    pub async fn get_by_server_id(
        &self,
        server_id: &str,
    ) -> Result<Option<ExchangeRateModel>, DatabaseError> {
        self.database.get_by_column_id("server_id", server_id).await
    }

    pub async fn get_all(&self) -> Result<Vec<ExchangeRateModel>> {
        self.database.get_all().await
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::dao::exchange_rate_dao::ExchangeRateDao;
    use crate::proton_wallet::db::model::exchange_rate_model::ExchangeRateModel;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_exchange_rate_dao() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        {
            // create table
            let conn_arc_cp = Arc::clone(&conn_arc);
            let conn = conn_arc_cp.lock().await;
            let _ = conn.execute(
                r#"
                CREATE TABLE IF NOT EXISTS exchange_rate_table (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    server_id TEXT NOT NULL,
                    bitcoin_unit TEXT NOT NULL,
                    fiat_currency TEXT NOT NULL,
                    sign TEXT NOT NULL,
                    exchange_rate_time TEXT NOT NULL,
                    exchange_rate INTEGER NOT NULL,
                    cents INTEGER NOT NULL
                )
                "#,
                [],
            );
        }
        let exchange_rate_dao = ExchangeRateDao::new(conn_arc);
        let exchange_rates = exchange_rate_dao.get_all().await.unwrap();
        assert_eq!(exchange_rates.len(), 0);

        let mut exchange_rate = ExchangeRateModel {
            id: Some(1),
            server_id: "server_001".to_string(),
            bitcoin_unit: "BTC".to_string(),
            fiat_currency: "USD".to_string(),
            sign: "$".to_string(),
            exchange_rate_time: "2024-09-18T12:00:00Z".to_string(),
            exchange_rate: 50000,
            cents: 99,
        };

        // test insert
        let upsert_result = exchange_rate_dao
            .upsert(&exchange_rate)
            .await
            .unwrap()
            .unwrap();
        assert_eq!(upsert_result.id.unwrap(), 1);

        // test query
        let query_item = exchange_rate_dao
            .get(upsert_result.id.unwrap())
            .await
            .unwrap()
            .unwrap();
        assert_eq!(query_item.server_id, "server_001");
        assert_eq!(query_item.bitcoin_unit, "BTC");
        assert_eq!(query_item.fiat_currency, "USD");
        assert_eq!(query_item.sign, "$");
        assert_eq!(query_item.exchange_rate_time, "2024-09-18T12:00:00Z");
        assert_eq!(query_item.exchange_rate, 50000);
        assert_eq!(query_item.cents, 99);

        let exchange_rates = exchange_rate_dao.get_all().await.unwrap();
        assert_eq!(exchange_rates.len(), 1);

        // test update
        exchange_rate.bitcoin_unit = "MBTC".to_string();
        exchange_rate.fiat_currency = "CHF".to_string();
        exchange_rate.exchange_rate = 9999;
        exchange_rate.cents = 1;
        let upsert_result = exchange_rate_dao
            .upsert(&exchange_rate)
            .await
            .unwrap()
            .unwrap();
        assert_eq!(upsert_result.id.unwrap(), 1);

        let query_item = exchange_rate_dao
            .get_by_server_id(&exchange_rate.server_id)
            .await
            .unwrap()
            .unwrap();
        assert_eq!(query_item.server_id, "server_001");
        assert_eq!(query_item.bitcoin_unit, "MBTC");
        assert_eq!(query_item.fiat_currency, "CHF");
        assert_eq!(query_item.sign, "$");
        assert_eq!(query_item.exchange_rate_time, "2024-09-18T12:00:00Z");
        assert_eq!(query_item.exchange_rate, 9999);
        assert_eq!(query_item.cents, 1);
    }
}

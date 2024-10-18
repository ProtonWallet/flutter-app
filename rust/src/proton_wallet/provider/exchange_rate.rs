use super::{provider::DataProvider, Result};
use crate::proton_wallet::db::{
    dao::exchange_rate_dao::ExchangeRateDao, model::exchange_rate_model::ExchangeRateModel,
};

pub struct ExchangeRateDataProvider {
    dao: ExchangeRateDao,
}

impl ExchangeRateDataProvider {
    pub fn new(dao: ExchangeRateDao) -> Self {
        ExchangeRateDataProvider { dao }
    }

    pub async fn get_all(&mut self) -> Result<Vec<ExchangeRateModel>> {
        Ok(self.dao.get_all().await?)
    }
}

impl DataProvider<ExchangeRateModel> for ExchangeRateDataProvider {
    async fn upsert(&mut self, item: ExchangeRateModel) -> Result<()> {
        let result = self.dao.upsert(&item).await;
        result?;
        Ok(())
    }

    async fn get(&mut self, server_id: &str) -> Result<Option<ExchangeRateModel>> {
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
    async fn test_exchange_rate_provider() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let exchange_rate_dao = ExchangeRateDao::new(conn_arc.clone());
        let _ = exchange_rate_dao.database.migration_0().await;
        let mut exchange_rate_provider = ExchangeRateDataProvider::new(exchange_rate_dao);

        let exchange_rate1 = ExchangeRateModel {
            id: Some(1),
            server_id: "server_001".to_string(),
            bitcoin_unit: "BTC".to_string(),
            fiat_currency: "USD".to_string(),
            sign: "$".to_string(),
            exchange_rate_time: "2024-09-18T12:00:00Z".to_string(),
            exchange_rate: 50000,
            cents: 99,
        };

        let exchange_rate2 = ExchangeRateModel {
            id: Some(1),
            server_id: "server_002".to_string(),
            bitcoin_unit: "SATS".to_string(),
            fiat_currency: "CHF".to_string(),
            sign: "ch".to_string(),
            exchange_rate_time: "2024-09-18T12:00:00Z".to_string(),
            exchange_rate: 10000,
            cents: 2,
        };

        let _ = exchange_rate_provider.upsert(exchange_rate1.clone()).await;
        let _ = exchange_rate_provider.upsert(exchange_rate2.clone()).await;

        // Test get
        let fetched_exchange_rate1 = exchange_rate_provider
            .get("server_001")
            .await
            .expect("Failed to get exchange rate")
            .expect("Exchange rate not found");
        assert_eq!(fetched_exchange_rate1.server_id, exchange_rate1.server_id);

        // Test get_all
        let all_exchange_rates = exchange_rate_provider
            .get_all()
            .await
            .expect("Failed to get all exchange rates");
        assert_eq!(all_exchange_rates.len(), 2);
        assert_eq!(all_exchange_rates[0].server_id, exchange_rate1.server_id);
        assert_eq!(all_exchange_rates[1].server_id, exchange_rate2.server_id);
    }
}

use andromeda_api::{core::ApiClient, transaction::ExchangeRateOrTransactionTime};
use chrono::Utc;
use log::info;
use std::sync::Arc;

use crate::{api::rust_api::Transaction, proton_api::errors::ApiError};

use super::proton_api_service::ProtonAPIService;

use bdk::bitcoin::consensus::serialize;
pub use bdk::bitcoin::Transaction as bdkTransaction;
use bitcoin_internals::hex::display::DisplayHex;

pub struct TransactionClient {
    pub inner: Arc<andromeda_api::transaction::TransactionClient>,
}

impl TransactionClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(andromeda_api::transaction::TransactionClient::new(
                service.inner.clone(),
            )),
        }
    }

    #[allow(clippy::too_many_arguments)]
    pub async fn broadcast_raw_transaction(
        &self,
        signed_transaction_hex: String,
        wallet_id: String,
        wallet_account_id: String,
        label: Option<String>,
        exchange_rate_id: Option<String>,
        transaction_time: Option<String>,
        address_id: Option<String>,
        subject: Option<String>,
        body: Option<String>,
    ) -> Result<String, ApiError> {
        let transaction: Transaction = signed_transaction_hex.into();
        let bdk_transaction: &bdkTransaction = &transaction.internal;

        let signed_transaction_hex = serialize(bdk_transaction).to_lower_hex_string();
        info!("signed_transaction_hex: {}", signed_transaction_hex);
        let exchange_rate_or_transaction_time = if let Some(exchange_rate_id) = exchange_rate_id {
            ExchangeRateOrTransactionTime::ExchangeRate(exchange_rate_id)
        } else if let Some(transaction_time) = transaction_time {
            ExchangeRateOrTransactionTime::TransactionTime(transaction_time)
        } else {
            ExchangeRateOrTransactionTime::TransactionTime(Utc::now().timestamp().to_string())
        };
        let result = self
            .inner
            .broadcast_raw_transaction(
                signed_transaction_hex,
                wallet_id,
                wallet_account_id,
                label,
                exchange_rate_or_transaction_time,
                address_id,
                subject,
                body,
            )
            .await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn get_raw_transaction(&self, txid: String) -> Result<bdkTransaction, ApiError> {
        Ok(self.inner.get_raw_transaction(txid).await?)
    }
}

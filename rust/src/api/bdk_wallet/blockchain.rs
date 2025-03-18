use std::{collections::HashMap, ops::Deref, sync::Arc};

use andromeda_api::transaction::{
    BroadcastMessage, ExchangeRateOrTransactionTime, RecommendedFees,
};
use andromeda_bitcoin::{blockchain_client::BlockchainClient, psbt::Psbt};
use chrono::Utc;
use flutter_rust_bridge::frb;
use tracing::info;

use super::psbt::FrbPsbt;
use crate::api::{
    api_service::proton_api_service::ProtonAPIService, errors::BridgeError,
    proton_api::retrieve_proton_api,
};

#[derive(Clone)]
pub struct FrbBlockchainClient {
    pub(crate) inner: Arc<BlockchainClient>,
}

impl FrbBlockchainClient {
    #[frb(ignore)]
    pub(crate) fn get_inner(&self) -> Arc<BlockchainClient> {
        self.inner.clone()
    }
}

impl FrbBlockchainClient {
    #[frb(sync)]
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(andromeda_bitcoin::blockchain_client::BlockchainClient::new(
                service.inner.clone(),
            )),
        }
    }

    pub async fn get_fees_estimation(&mut self) -> Result<HashMap<String, f64>, BridgeError> {
        Ok(self.get_inner().get_fees_estimation().await?)
    }

    pub async fn get_recommended_fees(&self) -> Result<RecommendedFees, BridgeError> {
        Ok(self.get_inner().get_recommended_fees().await?)
    }

    #[allow(clippy::too_many_arguments)]
    pub async fn broadcast_psbt(
        &self,
        psbt: &FrbPsbt,
        wallet_id: String,
        wallet_account_id: String,
        label: Option<String>,
        exchange_rate_id: Option<String>,
        transaction_time: Option<String>,
        address_id: Option<String>,
        body: Option<String>,
        message: Option<BroadcastMessage>,
        recipients: Option<HashMap<String, String>>,
        is_anonymous: Option<u8>,
    ) -> Result<String, BridgeError> {
        let tx = psbt.extract_tx()?;

        let compute_txid = tx.compute_txid();

        info!("signed_transaction_hex: {}", compute_txid);
        let exchange_rate_or_transaction_time = if let Some(exchange_rate_id) = exchange_rate_id {
            ExchangeRateOrTransactionTime::ExchangeRate(exchange_rate_id)
        } else if let Some(transaction_time) = transaction_time {
            ExchangeRateOrTransactionTime::TransactionTime(transaction_time)
        } else {
            ExchangeRateOrTransactionTime::TransactionTime(Utc::now().timestamp().to_string())
        };

        self.inner
            .broadcast(
                tx.clone_inner(),
                wallet_id,
                wallet_account_id,
                label,
                exchange_rate_or_transaction_time,
                address_id,
                body,
                message,
                recipients,
                is_anonymous,
            )
            .await?;

        Ok(compute_txid)
    }
}

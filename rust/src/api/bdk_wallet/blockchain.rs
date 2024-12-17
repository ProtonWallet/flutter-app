use andromeda_api::transaction::{
    BroadcastMessage, ExchangeRateOrTransactionTime, RecommendedFees,
};
use andromeda_bitcoin::blockchain_client::BlockchainClient;
use chrono::Utc;
use flutter_rust_bridge::frb;
use std::{collections::HashMap, ops::Deref, sync::Arc};
use tracing::info;

use super::{account::FrbAccount, psbt::FrbPsbt};
use crate::api::{
    api_service::proton_api_service::ProtonAPIService, errors::BridgeError,
    proton_api::retrieve_proton_api,
};

pub struct FrbBlockchainClient {
    pub(crate) inner: BlockchainClient,
}

impl From<BlockchainClient> for FrbBlockchainClient {
    fn from(inner: BlockchainClient) -> Self {
        FrbBlockchainClient { inner }
    }
}
impl FrbBlockchainClient {
    #[frb(sync)]
    pub fn create_esplora_blockchain() -> Result<FrbBlockchainClient, BridgeError> {
        let proton_api = retrieve_proton_api()?;
        let blockchain = FrbBlockchainClient::new(proton_api)?;
        Ok(blockchain)
    }

    #[frb(sync)]
    pub fn new(api_service: Arc<ProtonAPIService>) -> Result<FrbBlockchainClient, BridgeError> {
        let inner = BlockchainClient::new(api_service.inner.deref().clone());
        Ok(FrbBlockchainClient { inner })
    }

    pub async fn get_fees_estimation(&mut self) -> Result<HashMap<String, f64>, BridgeError> {
        Ok(self.inner.get_fees_estimation().await?)
    }

    pub async fn get_recommended_fees(&self) -> Result<RecommendedFees, BridgeError> {
        Ok(self.inner.get_recommended_fees().await?)
    }

    pub async fn full_sync(
        &self,
        account: &FrbAccount,
        stop_gap: Option<usize>,
    ) -> Result<(), BridgeError> {
        let account_inner = account.get_inner();
        let update = self.inner.full_sync(&account_inner, stop_gap).await?;
        account_inner.apply_update(update).await?;

        Ok(())
    }

    pub async fn partial_sync(&self, account: &FrbAccount) -> Result<(), BridgeError> {
        let account_inner = account.get_inner();

        let read_lock = account_inner.get_wallet().await;
        let update = self.inner.partial_sync(read_lock).await?;

        account_inner.apply_update(update).await?;

        Ok(())
    }

    pub async fn should_sync(&self, account: &FrbAccount) -> Result<bool, BridgeError> {
        let account_inner = account.get_inner();

        let wallet_lock = account_inner.get_wallet().await;

        Ok(self.inner.should_sync(wallet_lock).await?)
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

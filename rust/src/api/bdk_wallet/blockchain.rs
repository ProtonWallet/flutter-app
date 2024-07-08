use andromeda_api::transaction::ExchangeRateOrTransactionTime;
use chrono::Utc;
// blockchain.rs
use flutter_rust_bridge::frb;

use andromeda_bitcoin::blockchain_client::BlockchainClient;
use std::{collections::HashMap, ops::Deref, sync::Arc};

use super::{account::FrbAccount, psbt::FrbPsbt};
use crate::{api::api_service::proton_api_service::ProtonAPIService, BridgeError};

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
    pub fn new(api_service: Arc<ProtonAPIService>) -> Result<FrbBlockchainClient, BridgeError> {
        let inner = BlockchainClient::new(api_service.inner.deref().clone());
        Ok(FrbBlockchainClient { inner })
    }

    pub async fn get_fees_estimation(&mut self) -> Result<HashMap<String, f64>, BridgeError> {
        Ok(self.inner.get_fees_estimation().await?)
    }

    pub async fn full_sync(
        &self,
        account: &FrbAccount,
        stop_gap: Option<usize>,
    ) -> Result<(), BridgeError> {
        let account_inner = account.get_inner();

        let read_lock = account_inner.get_wallet().await;
        let update = self.inner.full_sync(read_lock, stop_gap).await?;

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
        subject: Option<String>,
        body: Option<String>,
    ) -> Result<String, BridgeError> {
        let tx = psbt.extract_tx()?;

        let compute_txid = tx.compute_txid();

        println!("signed_transaction_hex: {}", compute_txid);
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
                subject,
                body,
            )
            .await?;

        Ok(compute_txid)
    }
}

// account.rs

use andromeda_api::exchange_rate::ApiExchangeRate;
use andromeda_bitcoin::{
    account::Account, account_trait::AccessWallet, transactions::Pagination, utils::SortOrder,
    KeychainKind, SignOptions, TransactionFilter,
};
use andromeda_common::Network;
use tracing::debug;

use crate::{common::address_info::FrbAddressInfo, exchange_rate::ProtonExchangeRate, BridgeError};
use flutter_rust_bridge::frb;
use std::sync::Arc;

use super::{
    address::{FrbAddress, FrbAddressDetails},
    balance::FrbBalance,
    blockchain::FrbBlockchainClient,
    local_output::FrbLocalOutput,
    psbt::FrbPsbt,
    transaction_builder::FrbTxBuilder,
    transaction_details::FrbTransactionDetails,
};

#[derive(Clone)]
pub struct FrbAccount {
    inner: Arc<Account>,
}

impl FrbAccount {
    #[frb(ignore)]
    pub(crate) fn get_inner(&self) -> Arc<Account> {
        self.inner.clone()
    }
}

impl From<Arc<Account>> for FrbAccount {
    fn from(value: Arc<Account>) -> Self {
        FrbAccount { inner: value }
    }
}
impl From<FrbAccount> for Arc<Account> {
    fn from(value: FrbAccount) -> Self {
        value.inner
    }
}

impl FrbAccount {
    pub async fn get_address(&self, index: Option<u32>) -> Result<FrbAddressInfo, BridgeError> {
        let account_inner = self.inner.clone();

        let address = if let Some(idx) = index {
            account_inner.peek_receive_address(idx).await?
        } else {
            account_inner.get_next_receive_address().await?
        };

        Ok(address.into())
    }

    pub async fn mark_receive_addresses_used_to(
        &self,
        from: u32,
        to: Option<u32>,
    ) -> Result<(), BridgeError> {
        let account_inner = self.inner.clone();
        account_inner
            .mark_receive_addresses_used_to(from, to)
            .await?;

        Ok(())
    }

    pub async fn get_next_receive_address(&self) -> Result<FrbAddressInfo, BridgeError> {
        let account_inner = self.inner.clone();
        let address = account_inner.get_next_receive_address().await?;

        Ok(address.into())
    }

    pub async fn is_mine(&self, address: &FrbAddress) -> Result<bool, BridgeError> {
        let owns = self.get_inner().owns(&address.clone_inner()).await;
        Ok(owns)
    }

    pub async fn get_balance(&self) -> FrbBalance {
        self.get_inner().get_balance().await.into()
    }

    pub fn get_derivation_path(&self) -> Result<String, BridgeError> {
        let derivation_path = self.inner.get_derivation_path().to_string();
        Ok(derivation_path)
    }

    pub async fn get_utxos(&self) -> Result<Vec<FrbLocalOutput>, BridgeError> {
        let utxos = self.inner.get_utxos().await;

        let outputs = utxos.into_iter().map(FrbLocalOutput::from).collect();

        Ok(outputs)
    }

    pub async fn get_transactions(
        &self,
        sort: Option<SortOrder>,
        filter: TransactionFilter,
    ) -> Result<Vec<FrbTransactionDetails>, BridgeError> {
        let transactions = self
            .inner
            .get_transactions(Pagination::default(), sort, filter)
            .await?;

        debug!("BDK Debug: get_transactions count: {}", transactions.len());

        let out_transactions = transactions
            .into_iter()
            .map(FrbTransactionDetails::from)
            .collect();

        Ok(out_transactions)
    }

    pub async fn get_transaction(
        &self,
        txid: String,
    ) -> Result<FrbTransactionDetails, BridgeError> {
        let transaction = self.inner.get_transaction(txid).await?;

        Ok(transaction.into())
    }

    pub async fn has_sync_data(&self) -> bool {
        self.inner.has_sync_data().await
    }

    pub async fn sign(&self, psbt: &mut FrbPsbt, network: Network) -> Result<FrbPsbt, BridgeError> {
        let mut psbt = psbt.clone_inner().inner();
        self.inner
            .sign(&mut psbt, Some(SignOptions::default()))
            .await?;

        FrbPsbt::from_psbt(&psbt.into(), network)
    }

    pub async fn build_tx(&self) -> Result<FrbTxBuilder, BridgeError> {
        let mut tx_builder = FrbTxBuilder::new();
        tx_builder = tx_builder.clear_recipients();
        tx_builder = tx_builder.set_account(self).await?;

        Ok(tx_builder)
    }

    pub async fn bump_transactions_fees(
        &self,
        txid: String,
        fees: u64,
        network: Network,
    ) -> Result<FrbPsbt, BridgeError> {
        let psbt = self.inner.bump_transactions_fees(txid, fees).await?;
        FrbPsbt::from_psbt(&psbt, network)
    }

    pub async fn get_highest_used_address_index_in_output(
        &self,
        keychain: KeychainKind,
    ) -> Result<Option<u32>, BridgeError> {
        let highest = self
            .inner
            .get_highest_used_address_index_in_output(keychain)
            .await?;
        Ok(highest)
    }

    pub async fn get_maximum_gap_size(
        &self,
        keychain: KeychainKind,
    ) -> Result<Option<u32>, BridgeError> {
        let highest = self.inner.get_maximum_gap_size(keychain).await?;
        Ok(highest)
    }

    pub fn get_stop_gap_range(&self, max_gap: u32) -> Result<u32, BridgeError> {
        let ranged_stop_gap = self.inner.get_stop_gap_range(max_gap)?;
        Ok(ranged_stop_gap)
    }

    pub async fn get_address_from_graph(
        &self,
        network: Network,
        address_str: String,
        client: &FrbBlockchainClient,
        sync: bool,
    ) -> Result<Option<FrbAddressDetails>, BridgeError> {
        let address_detail = self
            .inner
            .get_address(network, address_str, client.get_inner(), sync)
            .await?;

        match address_detail {
            Some(address_detail) => Ok(Some(address_detail.into())),
            None => Ok(None),
        }
    }

    pub async fn get_addresses_from_graph(
        &self,
        pagination: Pagination,
        client: &FrbBlockchainClient,
        keychain: KeychainKind,
        sync: bool,
    ) -> Result<Vec<FrbAddressDetails>, BridgeError> {
        let address_detail = self
            .inner
            .get_addresses(pagination, client.get_inner(), keychain, sync)
            .await?;

        Ok(address_detail
            .into_iter()
            .map(|element| element.into())
            .collect())
    }

    pub async fn get_xpub(&self) -> Option<String> {
        if let Ok(xpub) = self.inner.get_xpub().await {
            Some(xpub.to_string())
        } else {
            None
        }
    }
}

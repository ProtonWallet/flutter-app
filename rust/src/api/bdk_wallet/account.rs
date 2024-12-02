// account.rs

use andromeda_bitcoin::{
    account::Account, transactions::Pagination, utils::SortOrder, SignOptions,
};
use andromeda_common::{Network, ScriptType};
use tracing::debug;

use crate::{
    common::address_info::FrbAddressInfo,
    proton_bdk::storage::{WalletMobileConnector, WalletMobilePersister},
    BridgeError,
};
use flutter_rust_bridge::frb;
use std::sync::Arc;

use super::{
    address::FrbAddress, balance::FrbBalance, derivation_path::FrbDerivationPath,
    local_output::FrbLocalOutput, psbt::FrbPsbt, storage::WalletMobileConnectorFactory,
    transaction_builder::FrbTxBuilder, transaction_details::FrbTransactionDetails,
    wallet::FrbWallet,
};

pub struct FrbAccount {
    pub(crate) inner: Arc<Account<WalletMobileConnector, WalletMobilePersister>>,
}

impl FrbAccount {
    #[frb(ignore)]
    pub(crate) fn get_inner(&self) -> Arc<Account<WalletMobileConnector, WalletMobilePersister>> {
        self.inner.clone()
    }
}

impl From<Arc<Account<WalletMobileConnector, WalletMobilePersister>>> for FrbAccount {
    fn from(value: Arc<Account<WalletMobileConnector, WalletMobilePersister>>) -> Self {
        FrbAccount { inner: value }
    }
}

impl FrbAccount {
    /// Usually creating account need to through wallet.
    ///  this shouldn't be used. just for sometimes we need it without wallet.
    #[frb(sync)]
    pub fn new(
        wallet: &FrbWallet,
        script_type: ScriptType,
        derivation_path: FrbDerivationPath,
        storage_factory: WalletMobileConnectorFactory,
    ) -> Result<FrbAccount, BridgeError> {
        let (mprv, network) = wallet.get_inner().mprv();
        let account = Account::new(
            mprv,
            network,
            script_type.into(),
            (&derivation_path).clone_inner(),
            storage_factory,
        )?;

        Ok(FrbAccount {
            inner: Arc::new(account),
        })
    }

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

    // pub async fn get_bitcoin_uri(
    //     &mut self,
    //     amount: Option<u64>,
    //     label: Option<String>,
    //     message: Option<String>,
    // ) -> Result<FrbPaymentLink, BridgeError> {
    //     let mut account_inner = self.get_inner_ref();
    //     let payment_link = account_inner
    //         .get_bitcoin_uri(amount, label, message)
    //         .await?;
    //     Ok(payment_link.into())
    // }

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
    ) -> Result<Vec<FrbTransactionDetails>, BridgeError> {
        let transactions = self
            .inner
            .get_transactions(Pagination::default(), sort)
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

    pub async fn insert_unconfirmed_tx(&self, psbt: &FrbPsbt) -> Result<(), BridgeError> {
        let transaction = psbt.extract_tx()?;

        self.inner.insert_unconfirmed_tx(transaction.inner).await?;

        Ok(())
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
        FrbPsbt::from_psbt(&psbt.into(), network)
    }
}

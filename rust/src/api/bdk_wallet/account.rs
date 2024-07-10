// account.rs
use flutter_rust_bridge::frb;

use andromeda_bitcoin::{
    account::Account, transactions::Pagination, utils::SortOrder, SignOptions,
};
use andromeda_common::{Network, ScriptType};

use crate::{common::address_info::FrbAddressInfo, BridgeError};

use super::{
    address::FrbAddress,
    balance::FrbBalance,
    derivation_path::FrbDerivationPath,
    local_output::FrbLocalOutput,
    payment_link::FrbPaymentLink,
    psbt::FrbPsbt,
    storage::{OnchainStore, OnchainStoreFactory},
    transaction_builder::FrbTxBuilder,
    transaction_details::FrbTransactionDetails,
    wallet::FrbWallet,
};

#[derive(Debug, Clone)]
pub struct FrbAccount {
    pub(crate) inner: Account<OnchainStore>,
}

impl FrbAccount {
    pub(crate) fn get_inner(&self) -> Account<OnchainStore> {
        self.inner.clone()
    }
}

impl From<Account<OnchainStore>> for FrbAccount {
    fn from(value: Account<OnchainStore>) -> Self {
        FrbAccount { inner: value }
    }
}

impl From<&Account<OnchainStore>> for FrbAccount {
    fn from(value: &Account<OnchainStore>) -> Self {
        FrbAccount {
            inner: value.clone(),
        }
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
        storage_factory: OnchainStoreFactory,
    ) -> Result<FrbAccount, BridgeError> {
        let (mprv, network) = wallet.get_inner().mprv();
        let account = Account::new(
            mprv,
            network,
            script_type.into(),
            (&derivation_path).clone_inner(),
            storage_factory,
        )?;

        Ok(FrbAccount { inner: account })
    }

    pub async fn get_address(&self, index: Option<u32>) -> Result<FrbAddressInfo, BridgeError> {
        let account_inner = self.get_inner();

        let address = account_inner.get_address(index).await?;

        Ok(address.into())
    }

    #[deprecated(
        note = "this fn returns next unused spk after of last unused. please use `get_index_after_last_used_address` instead"
    )]
    pub async fn get_last_unused_address_index(&self) -> Option<u32> {
        let account_inner = self.get_inner();
        account_inner.get_last_unused_address_index().await
    }

    pub async fn get_index_after_last_used_address(&self) -> u32 {
        let account_inner = self.get_inner();
        account_inner.get_index_after_last_used_address().await
    }

    pub async fn get_bitcoin_uri(
        &mut self,
        index: Option<u32>,
        amount: Option<u64>,
        label: Option<String>,
        message: Option<String>,
    ) -> Result<FrbPaymentLink, BridgeError> {
        let mut account_inner = self.get_inner();

        let payment_link = account_inner
            .get_bitcoin_uri(index, amount, label, message)
            .await?;
        Ok(payment_link.into())
    }

    pub async fn is_mine(&self, address: &FrbAddress) -> Result<bool, BridgeError> {
        let owns = self.inner.owns(&address.clone_inner()).await;

        Ok(owns)
    }

    pub async fn get_balance(&self) -> FrbBalance {
        self.inner.get_balance().await.into()
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
        pagination: Option<Pagination>,
        sort: Option<SortOrder>,
    ) -> Result<Vec<FrbTransactionDetails>, BridgeError> {
        let transactions = self.inner.get_transactions(pagination, sort).await?;

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
        tx_builder = tx_builder.set_account(&self.clone()).await?;

        Ok(tx_builder)
    }
}

// transaction_details.rs
use andromeda_bitcoin::transactions::{TransactionDetails, TransactionTime};
use flutter_rust_bridge::frb;

use super::{
    transaction_details_txin::FrbDetailledTxIn, transaction_details_txop::FrbDetailledTxOutput,
};
use crate::api::bdk_wallet::derivation_path::FrbDerivationPath;

#[derive(Clone, Debug)]
pub struct FrbTransactionDetails {
    /// Transaction id
    pub(crate) txid: String,
    /// Received value (sats)
    /// Sum of owned outputs of this transaction.
    pub(crate) received: u64,
    /// Sent value (sats)
    /// Sum of owned inputs of this transaction.
    pub(crate) sent: u64,
    /// Fee value (sats) if confirmed.
    /// The availability of the fee depends on the backend. It's never `None`
    /// with an Electrum Server backend, but it could be `None` with a
    /// Bitcoin RPC node without txindex that receive funds while offline.
    pub(crate) fees: Option<u64>,
    /// Transaction size in vbytes.
    /// Can be used to compute feerate for transaction given an absolute fee
    /// amount
    pub(crate) vbytes_size: u64,
    /// If the transaction is confirmed, contains height and Unix timestamp of
    /// the block containing the transaction, unconfirmed transaction
    /// contains `None`.
    pub(crate) time: TransactionTime,
    /// List of transaction inputs.
    pub(crate) inputs: Vec<FrbDetailledTxIn>,
    /// List of transaction outputs.
    pub(crate) outputs: Vec<FrbDetailledTxOutput>,
    /// BIP44 Account to which the transaction is bound
    pub(crate) account_derivation_path: FrbDerivationPath,
}

impl FrbTransactionDetails {
    #[frb(getter, sync)]
    pub fn txid(&self) -> String {
        self.txid.clone()
    }

    #[frb(getter, sync)]
    pub fn received(&self) -> u64 {
        self.received
    }

    #[frb(getter, sync)]
    pub fn sent(&self) -> u64 {
        self.sent
    }

    #[frb(getter, sync)]
    pub fn fees(&self) -> Option<u64> {
        self.fees
    }

    #[frb(getter, sync)]
    pub fn vbytes_size(&self) -> u64 {
        self.vbytes_size
    }

    #[frb(getter, sync)]
    pub fn time(&self) -> TransactionTime {
        self.time
    }

    #[frb(getter, sync)]
    pub fn inputs(&self) -> Vec<FrbDetailledTxIn> {
        self.inputs.clone()
    }

    #[frb(getter, sync)]
    pub fn outputs(&self) -> Vec<FrbDetailledTxOutput> {
        self.outputs.clone()
    }

    #[frb(getter, sync)]
    pub fn account_derivation_path(&self) -> FrbDerivationPath {
        self.account_derivation_path.clone()
    }
}

impl From<TransactionDetails> for FrbTransactionDetails {
    fn from(transaction_details: TransactionDetails) -> Self {
        FrbTransactionDetails {
            txid: transaction_details.txid.to_string(),
            received: transaction_details.received,
            sent: transaction_details.sent,
            fees: transaction_details.fees,
            vbytes_size: transaction_details.vbytes_size,
            time: transaction_details.time,
            inputs: transaction_details
                .inputs
                .into_iter()
                .map(FrbDetailledTxIn::from)
                .collect(),
            outputs: transaction_details
                .outputs
                .into_iter()
                .map(FrbDetailledTxOutput::from)
                .collect(),
            account_derivation_path: transaction_details.account_derivation_path.into(),
        }
    }
}

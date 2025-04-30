// transaction_details.rs
use andromeda_bitcoin::transactions::{TransactionDetails, TransactionTime};
use flutter_rust_bridge::frb;

use super::transaction_details_txop::FrbDetailledTxOutput;
use crate::api::bdk_wallet::derivation_path::FrbDerivationPath;

#[derive(Clone, Debug)]
pub struct FrbTransactionDetails {
    pub(crate) inner: TransactionDetails,
}

impl FrbTransactionDetails {
    #[frb(getter, sync)]
    pub fn txid(&self) -> String {
        self.inner.txid.to_string()
    }

    #[frb(getter, sync)]
    pub fn is_send(&self) -> bool {
        self.inner.is_send()
    }

    #[frb(getter, sync)]
    pub fn get_value(&self) -> u64 {
        self.inner.get_value()
    }

    #[frb(getter, sync)]
    pub fn get_value_with_fee(&self) -> u64 {
        self.inner.get_value_with_fee()
    }

    #[frb(getter, sync)]
    #[frb(getter, sync)]
    pub fn fees(&self) -> Option<u64> {
        self.inner.fees
    }

    #[frb(getter, sync)]
    pub fn vbytes_size(&self) -> u64 {
        self.inner.vbytes_size
    }

    #[frb(getter, sync)]
    pub fn time(&self) -> TransactionTime {
        self.inner.time
    }

    #[frb(getter, sync)]
    pub fn outputs(&self) -> Vec<FrbDetailledTxOutput> {
        self.inner
            .outputs
            .clone()
            .into_iter()
            .map(FrbDetailledTxOutput::from)
            .collect()
    }

    #[frb(getter, sync)]
    pub fn account_derivation_path(&self) -> FrbDerivationPath {
        self.inner.account_derivation_path.clone().into()
    }
}

impl From<TransactionDetails> for FrbTransactionDetails {
    fn from(transaction_details: TransactionDetails) -> Self {
        FrbTransactionDetails {
            inner: transaction_details,
        }
    }
}

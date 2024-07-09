// local_output.rs

use andromeda_bitcoin::{ConfirmationTime, KeychainKind, LocalOutput, OutPoint, TxOut};
use flutter_rust_bridge::frb;

use super::amount::FrbAmount;
use crate::api::bdk_wallet::script_buf::FrbScriptBuf;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct FrbLocalOutput {
    /// Reference to a transaction output
    pub(crate) outpoint: FrbOutPoint,
    /// Transaction output
    pub(crate) txout: FrbTxOut,
    /// Type of keychain
    pub(crate) keychain: KeychainKind,
    /// Whether this UTXO is spent or not
    pub(crate) is_spent: bool,
    /// The derivation index for the script pubkey in the wallet
    pub(crate) derivation_index: u32,
    /// The confirmation time for transaction containing this utxo
    pub(crate) confirmation_time: ConfirmationTime,
}

impl From<LocalOutput> for FrbLocalOutput {
    fn from(local_utxo: LocalOutput) -> Self {
        Self {
            outpoint: local_utxo.outpoint.into(),
            txout: local_utxo.txout.into(),
            keychain: local_utxo.keychain,
            is_spent: local_utxo.is_spent,
            derivation_index: local_utxo.derivation_index,
            confirmation_time: local_utxo.confirmation_time,
        }
    }
}

impl FrbLocalOutput {
    #[frb(getter, sync)]
    pub fn outpoint(&self) -> FrbOutPoint {
        self.outpoint.clone()
    }

    #[frb(getter, sync)]
    pub fn txout(&self) -> FrbTxOut {
        self.txout.clone()
    }

    #[frb(getter, sync)]
    pub fn keychain(&self) -> KeychainKind {
        self.keychain.clone()
    }

    #[frb(getter, sync)]
    pub fn is_spent(&self) -> bool {
        self.is_spent.clone()
    }

    #[frb(getter, sync)]
    pub fn derivation_index(&self) -> u32 {
        self.derivation_index.clone()
    }

    #[frb(getter, sync)]
    pub fn confirmation_time(&self) -> ConfirmationTime {
        self.confirmation_time.clone()
    }
}

#[derive(Clone, Debug, Eq, Hash, PartialEq, PartialOrd, Ord)]
pub struct FrbOutPoint {
    /// The referenced transaction's txid.
    pub txid: String,
    /// The index of the referenced output in its transaction's vout.
    pub vout: u32,
}

impl From<OutPoint> for FrbOutPoint {
    fn from(txout: OutPoint) -> Self {
        Self {
            txid: txout.txid.to_string(),
            vout: txout.vout,
        }
    }
}

#[derive(Clone, PartialEq, Eq, PartialOrd, Ord, Debug, Hash)]
pub struct FrbTxOut {
    /// The value of the output, in satoshis.
    pub(crate) value: FrbAmount,
    /// The script which must be satisfied for the output to be spent.
    pub(crate) script_pubkey: FrbScriptBuf,
}

impl FrbTxOut {
    #[frb(getter, sync)]
    pub fn value(&self) -> FrbAmount {
        self.value.clone()
    }

    #[frb(getter, sync)]
    pub fn script_pubkey(&self) -> FrbScriptBuf {
        self.script_pubkey.clone()
    }
}

impl From<TxOut> for FrbTxOut {
    fn from(txout: TxOut) -> Self {
        Self {
            value: txout.value.into(),
            script_pubkey: txout.script_pubkey.into(),
        }
    }
}

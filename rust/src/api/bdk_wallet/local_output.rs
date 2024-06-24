// local_output.rs

use andromeda_bitcoin::{ConfirmationTime, KeychainKind, LocalOutput, OutPoint, TxOut};

use super::amount::FrbAmount;
use crate::api::bdk_wallet::script_buf::FrbScriptBuf;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct FrbLocalOutput {
    /// Reference to a transaction output
    pub outpoint: FrbOutPoint,
    /// Transaction output
    pub txout: FrbTxOut,
    /// Type of keychain
    pub keychain: KeychainKind,
    /// Whether this UTXO is spent or not
    pub is_spent: bool,
    /// The derivation index for the script pubkey in the wallet
    pub derivation_index: u32,
    /// The confirmation time for transaction containing this utxo
    pub confirmation_time: ConfirmationTime,
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
    pub value: FrbAmount,
    /// The script which must be satisfied for the output to be spent.
    pub script_pubkey: FrbScriptBuf,
}

impl From<TxOut> for FrbTxOut {
    fn from(txout: TxOut) -> Self {
        Self {
            value: txout.value.into(),
            script_pubkey: txout.script_pubkey.into(),
        }
    }
}

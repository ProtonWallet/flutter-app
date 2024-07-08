// transaction_details_txin.rs
use andromeda_bitcoin::transactions::DetailledTxIn;
use flutter_rust_bridge::frb;

use super::{sequence::FrbSequence, transaction_details_txop::FrbDetailledTxOutput};
use crate::api::bdk_wallet::script_buf::FrbScriptBuf;

#[derive(Clone, Debug)]
pub struct FrbDetailledTxIn {
    pub(crate) previous_output: Option<FrbDetailledTxOutput>, // Remove option when we know why some utxo are not found
    pub(crate) script_sig: FrbScriptBuf,
    pub(crate) sequence: FrbSequence,
    // pub witness: Witness,
}

impl From<DetailledTxIn> for FrbDetailledTxIn {
    fn from(detailled_tx_in: DetailledTxIn) -> Self {
        FrbDetailledTxIn {
            previous_output: detailled_tx_in
                .previous_output
                .map(FrbDetailledTxOutput::from),
            script_sig: detailled_tx_in.script_sig.into(),
            sequence: detailled_tx_in.sequence.into(),
            // witness: detailled_tx_in.witness,
        }
    }
}

impl FrbDetailledTxIn {
    #[inline]
    #[frb(getter, sync)]
    pub fn previous_output(&self) -> Option<FrbDetailledTxOutput> {
        self.previous_output.clone()
    }

    #[inline]
    #[frb(getter, sync)]
    pub fn script_sig(&self) -> FrbScriptBuf {
        self.script_sig.clone()
    }

    #[inline]
    #[frb(getter, sync)]
    pub fn sequence(&self) -> FrbSequence {
        self.sequence.clone()
    }
}

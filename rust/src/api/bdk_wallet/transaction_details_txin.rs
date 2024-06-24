// transaction_details_txin.rs
use andromeda_bitcoin::transactions::DetailledTxIn;

use super::{sequence::FrbSequence, transaction_details_txop::FrbDetailledTxOutput};
use crate::api::bdk_wallet::script_buf::FrbScriptBuf;

#[derive(Clone, Debug)]
pub struct FrbDetailledTxIn {
    pub previous_output: Option<FrbDetailledTxOutput>, // Remove option when we know why some utxo are not found
    pub script_sig: FrbScriptBuf,
    pub sequence: FrbSequence,
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

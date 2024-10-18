// transaction_details_txop.rs
use flutter_rust_bridge::frb;

use andromeda_bitcoin::transactions::DetailledTxOutput;

use crate::api::bdk_wallet::script_buf::FrbScriptBuf;

#[derive(Debug, Clone)]
pub struct FrbDetailledTxOutput {
    pub(crate) value: u64,
    pub(crate) address: Option<String>,
    pub(crate) script_pubkey: FrbScriptBuf,
    pub(crate) is_mine: bool,
}

impl From<DetailledTxOutput> for FrbDetailledTxOutput {
    fn from(detailled_tx_output: DetailledTxOutput) -> Self {
        FrbDetailledTxOutput {
            value: detailled_tx_output.value,
            address: detailled_tx_output.address.map(|obj| obj.to_string()),
            script_pubkey: detailled_tx_output.script_pubkey.into(),
            is_mine: detailled_tx_output.is_mine,
        }
    }
}

impl FrbDetailledTxOutput {
    #[frb(getter, sync)]
    pub fn address(&self) -> Option<String> {
        self.address.clone()
    }

    #[frb(getter, sync)]
    pub fn value(&self) -> u64 {
        self.value
    }

    #[frb(getter, sync)]
    pub fn script_pubkey(&self) -> FrbScriptBuf {
        self.script_pubkey.clone()
    }

    #[frb(getter, sync)]
    pub fn is_mine(&self) -> bool {
        self.is_mine
    }
}

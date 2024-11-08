// psbt.rs
use andromeda_bitcoin::psbt::Psbt;
use andromeda_common::Network;
use flutter_rust_bridge::frb;

use super::{amount::FrbAmount, transactions::FrbTransaction};
use crate::api::{bdk_wallet::address::FrbAddress, errors::BridgeError};

#[derive(Clone)]
pub struct FrbPsbtRecipient(pub String, pub u64);

#[derive(Clone)]
pub struct FrbPsbt {
    pub(crate) inner: Psbt,

    pub(crate) recipients: Vec<FrbPsbtRecipient>,
    pub(crate) total_fees: u64,
}

impl FrbPsbt {
    pub(crate) fn clone_inner(&self) -> Psbt {
        self.inner.clone()
    }

    #[frb(sync)]
    pub fn extract_tx(&self) -> Result<FrbTransaction, BridgeError> {
        Ok(self.inner.extract_tx()?.into())
    }

    #[frb(sync)]
    pub fn fee(&self) -> Result<FrbAmount, BridgeError> {
        Ok(self.inner.fee()?.into())
    }

    pub(crate) fn from_psbt(psbt: &Psbt, network: Network) -> Result<FrbPsbt, BridgeError> {
        let extracted_tx = psbt.extract_tx()?;
        let fee = psbt.fee()?;

        let recipients: Result<Vec<_>, BridgeError> = extracted_tx
            .output
            .into_iter()
            .map(|o| {
                let addr = FrbAddress::from_script(o.script_pubkey.into(), network)?;
                Ok(FrbPsbtRecipient(addr.to_string(), o.value.to_sat()))
            })
            .collect();

        let frb_psbt = FrbPsbt {
            inner: psbt.clone(),
            recipients: recipients?,
            total_fees: fee.to_sat(),
        };

        Ok(frb_psbt)
    }

    #[frb(getter, sync)]
    pub fn recipients(&self) -> Vec<FrbPsbtRecipient> {
        self.recipients.clone()
    }

    #[frb(getter, sync)]
    pub fn total_fees(&self) -> u64 {
        self.total_fees.clone()
    }
}

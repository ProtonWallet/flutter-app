// address.rs
use flutter_rust_bridge::frb;
use std::str::FromStr;

use andromeda_bitcoin::{Address as BdkAddress, ConsensusParams};
use andromeda_common::Network;

use crate::BridgeError;

use super::script_buf::FrbScriptBuf;

#[derive(Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct FrbAddress {
    inner: BdkAddress,
}

impl FrbAddress {
    pub(crate) fn clone_inner(&self) -> BdkAddress {
        self.inner.clone()
    }
}

impl FrbAddress {
    #[frb(sync)]
    pub fn new(address: String, network: Network) -> Result<Self, BridgeError> {
        let bdk_addr = BdkAddress::from_str(&address)
            .map_err(|e| BridgeError::AndromedaBitcoin(e.to_string()))?
            .require_network(network.into())
            .map_err(|e| BridgeError::AndromedaBitcoin(e.to_string()))?;

        Ok(FrbAddress { inner: bdk_addr })
    }

    #[frb(sync)]
    pub fn from_script(script: FrbScriptBuf, network: Network) -> Result<Self, BridgeError> {
        BdkAddress::from_script(&script.inner, ConsensusParams::new(network.into()))
            .map(|a| FrbAddress { inner: a })
            .map_err(|e| BridgeError::Generic(e.to_string()))
    }

    #[frb(sync)]
    pub fn to_string(&self) -> String {
        self.inner.to_string()
    }

    #[frb(sync)]
    pub fn into_script(&self) -> FrbScriptBuf {
        self.inner.script_pubkey().into()
    }
}

impl From<BdkAddress> for FrbAddress {
    fn from(address: BdkAddress) -> Self {
        FrbAddress { inner: address }
    }
}

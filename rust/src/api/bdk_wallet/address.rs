// address.rs
pub use andromeda_bitcoin::{
    address::AddressDetails, transactions::TransactionDetails, Balance, KeychainKind,
};
use andromeda_bitcoin::{Address as BdkAddress, ConsensusParams};
use andromeda_common::Network;
use flutter_rust_bridge::frb;
use std::str::FromStr;

use super::{
    balance::FrbBalance, script_buf::FrbScriptBuf, transaction_details::FrbTransactionDetails,
};
use crate::BridgeError;

#[derive(Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct FrbAddress {
    pub(crate) inner: BdkAddress,
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

#[derive(Clone, Debug)]
pub struct FrbAddressDetails {
    pub(crate) index: u32,
    pub(crate) address: String,
    pub(crate) transactions: Vec<FrbTransactionDetails>,
    pub(crate) balance: FrbBalance,
    pub(crate) keychain: KeychainKind,
}

impl FrbAddressDetails {
    #[frb(getter, sync)]
    pub fn index(&self) -> u32 {
        self.index.clone()
    }

    #[frb(getter, sync)]
    pub fn address(&self) -> String {
        self.address.clone()
    }

    #[frb(getter, sync)]
    pub fn transactions(&self) -> Vec<FrbTransactionDetails> {
        self.transactions.clone()
    }

    #[frb(getter, sync)]
    pub fn balance(&self) -> FrbBalance {
        self.balance.clone()
    }

    #[frb(getter, sync)]
    pub fn keychain(&self) -> KeychainKind {
        self.keychain.clone()
    }

    #[frb(getter, sync)]
    pub fn is_trans_empty(&self) -> bool {
        self.transactions().is_empty()
    }
}

impl From<AddressDetails> for FrbAddressDetails {
    fn from(address_details: AddressDetails) -> Self {
        FrbAddressDetails {
            index: address_details.index,
            address: address_details.address,
            transactions: address_details
                .transactions
                .into_iter()
                .map(|element| element.into())
                .collect(),
            balance: address_details.balance.into(),
            keychain: address_details.keychain,
        }
    }
}

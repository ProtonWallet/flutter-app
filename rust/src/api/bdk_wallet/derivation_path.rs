// derivation_path.rs
use andromeda_bitcoin::DerivationPath as BdkDerivationPath;
use andromeda_common::{FromParts, Network, ScriptType};
use flutter_rust_bridge::frb;
use std::str::FromStr;

use crate::BridgeError;

#[derive(Debug, Clone, PartialEq, Eq, Ord, PartialOrd, Hash)]
pub struct FrbDerivationPath {
    pub(crate) inner: BdkDerivationPath,
}

impl FrbDerivationPath {
    pub(crate) fn clone_inner(&self) -> BdkDerivationPath {
        self.inner.clone()
    }
}

impl From<BdkDerivationPath> for FrbDerivationPath {
    fn from(path: BdkDerivationPath) -> Self {
        Self { inner: path }
    }
}

impl FrbDerivationPath {
    #[frb(sync)]
    pub fn new(path: &str) -> Result<FrbDerivationPath, BridgeError> {
        let derivation_path = BdkDerivationPath::from_str(path)
            .map_err(|e| BridgeError::AndromedaBitcoin(e.to_string()))?;

        Ok(FrbDerivationPath {
            inner: derivation_path,
        })
    }

    #[frb(sync)]
    pub fn from_parts(
        script_type: ScriptType,
        network: Network,
        account_index: u32,
    ) -> FrbDerivationPath {
        Self {
            inner: BdkDerivationPath::from_parts(script_type, network.into(), account_index),
        }
    }
}

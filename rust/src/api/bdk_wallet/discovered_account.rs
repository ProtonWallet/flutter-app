use andromeda_bitcoin::DerivationPath;
use andromeda_common::ScriptType;
use flutter_rust_bridge::frb;

use crate::api::bdk_wallet::derivation_path::FrbDerivationPath;

pub struct DiscoveredAccount {
    pub(crate) script_type: ScriptType,
    pub(crate) index: u32,
    pub(crate) derivation_path: FrbDerivationPath,
}

impl DiscoveredAccount {
    #[frb(sync)]
    pub fn new(script_type: ScriptType, index: u32, derivation_path: FrbDerivationPath) -> Self {
        Self {
            script_type,
            index,
            derivation_path,
        }
    }

    #[frb(getter, sync)]
    pub fn script_type(&self) -> ScriptType {
        self.script_type
    }

    #[frb(getter, sync)]
    pub fn index(&self) -> u32 {
        self.index
    }

    #[frb(getter, sync)]
    pub fn derivation_path(&self) -> FrbDerivationPath {
        self.derivation_path.clone()
    }
}

impl From<(ScriptType, u32, DerivationPath)> for DiscoveredAccount {
    fn from(value: (ScriptType, u32, DerivationPath)) -> Self {
        DiscoveredAccount {
            script_type: value.0,
            index: value.1,
            derivation_path: value.2.into(),
        }
    }
}

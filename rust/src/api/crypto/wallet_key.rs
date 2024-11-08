use flutter_rust_bridge::frb;

use crate::proton_wallet::crypto::wallet_key::{LockedWalletKey, UnlockedWalletKey};

pub struct FrbUnlockedWalletKey(pub(crate) UnlockedWalletKey);

impl FrbUnlockedWalletKey {
    pub(crate) fn new(key: UnlockedWalletKey) -> Self {
        Self(key)
    }

    #[frb(sync)]
    pub fn to_base64(&self) -> String {
        self.0.to_base64()
    }
    #[frb(sync)]
    pub fn to_entropy(&self) -> Vec<u8> {
        self.0.to_entropy()
    }
}

pub struct FrbLockedWalletKey(pub(crate) LockedWalletKey);

impl FrbLockedWalletKey {
    pub(crate) fn new(key: LockedWalletKey) -> Self {
        Self(key)
    }

    #[frb(sync)]
    pub fn get_armored(&self) -> String {
        self.0.get_armored()
    }

    #[frb(sync)]
    pub fn get_signature(&self) -> String {
        self.0.get_signature()
    }
}

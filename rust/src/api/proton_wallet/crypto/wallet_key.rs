use std::sync::Arc;

use flutter_rust_bridge::frb;

use crate::proton_wallet::crypto::wallet_key::{LockedWalletKey, UnlockedWalletKey};

pub struct FrbUnlockedWalletKey {
    pub(crate) inner: Arc<UnlockedWalletKey>,
}

impl FrbUnlockedWalletKey {
    pub(crate) fn new(key: UnlockedWalletKey) -> Self {
        Self {
            inner: Arc::new(key),
        }
    }

    #[frb(sync)]
    pub fn to_base64(&self) -> String {
        self.inner.to_base64()
    }

    #[frb(sync)]
    pub fn to_entropy(&self) -> Vec<u8> {
        self.inner.to_entropy()
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

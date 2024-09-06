use flutter_rust_bridge::frb;

pub use crate::proton_wallet::crypto::wallet_key::UnlockedWalletKey;

pub struct FrbUnlockedWalletKey(UnlockedWalletKey);

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

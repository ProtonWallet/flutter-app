// wallet_key_provider.rs
use flutter_rust_bridge::frb;

use crate::proton_wallet::crypto::wallet_key::{
    UnlockedWalletKey, WalletKeyInterface, WalletKeyProvider,
};

pub struct FrbWalletKeyProvider {}

impl FrbWalletKeyProvider {
    #[frb(sync)]
    pub fn generate_wallet_key() -> UnlockedWalletKey {
        WalletKeyProvider::generate()
    }
}

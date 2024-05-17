use std::sync::RwLock;

use andromeda_bitcoin::wallet::Wallet;
use andromeda_bitcoin::BdkMemoryDatabase;
use flutter_rust_bridge::frb;

use crate::bdk::error::Error;
use crate::bdk::types::Network;

// #[frb(opaque)]
pub struct BdkWalletManager {
    inner: RwLock<Wallet<BdkMemoryDatabase>>,
}

impl BdkWalletManager {
    pub fn new(
        network: Network,
        bip39_mnemonic: String,
        bip38_passphrase: Option<String>,
    ) -> Result<BdkWalletManager, Error> {
        let net: andromeda_common::Network = network.into();
        let result = andromeda_bitcoin::wallet::Wallet::new(net, bip39_mnemonic, bip38_passphrase);
        match result {
            Ok(wallet) => Ok(BdkWalletManager {
                inner: RwLock::new(wallet),
            }),
            Err(e) => Err(e.into()),
        }
    }

    #[frb(sync, getter)]
    pub fn fingerprint(&self) -> String {
        self.inner.read().unwrap().get_fingerprint()
    }
}

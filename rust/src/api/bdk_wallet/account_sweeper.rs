use andromeda_bitcoin::account_sweeper::AccountSweeper;
use andromeda_common::Network;
use flutter_rust_bridge::frb;

use crate::BridgeError;

use super::{account::FrbAccount, blockchain::FrbBlockchainClient, psbt::FrbPsbt};

#[derive(Clone)]
pub struct FrbAccountSweeper {
    inner: AccountSweeper,
}

impl FrbAccountSweeper {
    #[frb(sync)]
    pub fn new(client: &FrbBlockchainClient, account: &FrbAccount) -> Self {
        Self {
            inner: AccountSweeper::new(client.get_inner(), account.get_inner()),
        }
    }
}

impl FrbAccountSweeper {
    /// Sweep BTC from a WIF private key and its corresponding address into the user's wallet
    pub async fn psbt_sweep_from_wif(
        &self,
        wif: &str,
        sat_per_vb: u64,
        receive_address_index: Option<u32>,
        network: Network,
    ) -> Result<FrbPsbt, BridgeError> {
        let (psbt, _address) = self
            .inner
            .get_sweep_wif_psbt(wif, sat_per_vb, receive_address_index)
            .await?;
        FrbPsbt::from_psbt(&psbt, network)
    }
}

use andromeda_bitcoin::account_syncer::AccountSyncer;
use flutter_rust_bridge::frb;

use crate::BridgeError;

use super::{account::FrbAccount, blockchain::FrbBlockchainClient};

#[derive(Clone)]
pub struct FrbAccountSyncer {
    inner: AccountSyncer,
}

impl FrbAccountSyncer {
    #[frb(sync)]
    pub fn new(client: &FrbBlockchainClient, account: &FrbAccount) -> Self {
        Self {
            inner: AccountSyncer::new(client.get_inner(), account.get_inner()),
        }
    }
}

impl FrbAccountSyncer {
    pub async fn full_sync(&self, stop_gap: Option<usize>) -> Result<(), BridgeError> {
        Ok(self.inner.full_sync(stop_gap).await?)
    }

    pub async fn partial_sync(&self) -> Result<(), BridgeError> {
        Ok(self.inner.partial_sync().await?)
    }

    pub async fn should_sync(&self) -> Result<bool, BridgeError> {
        Ok(self.inner.should_sync().await?)
    }
}

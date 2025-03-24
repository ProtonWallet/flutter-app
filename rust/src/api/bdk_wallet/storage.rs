use std::sync::Arc;

use andromeda_bitcoin::storage::{Storage, WalletPersisterFactory};
use flutter_rust_bridge::frb;

use crate::proton_bdk::storage::WalletMobilePersister;

#[derive(Debug, Clone)]
pub struct WalletMobilePersisterFactory {
    pub(crate) folder_path: String,
}

impl WalletMobilePersisterFactory {
    #[frb(sync)]
    pub fn new(folder_path: String) -> Self {
        Self { folder_path }
    }
}

impl WalletPersisterFactory for WalletMobilePersisterFactory {
    fn build(self, key: String) -> Arc<dyn Storage> {
        #[allow(clippy::single_char_pattern)]
        let clean_key = key.replace("'", "_").replace("/", "_");
        let db_path = format!(
            "{}/proton_wallet_bdk_{}.sqlite",
            self.folder_path, clean_key
        );
        Arc::new(WalletMobilePersister::new(&db_path))
    }
}

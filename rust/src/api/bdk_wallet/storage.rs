use andromeda_bitcoin::storage::WalletConnectorFactory;
use flutter_rust_bridge::frb;

use crate::proton_bdk::storage::{WalletMobileConnector, WalletMobilePersister};

#[derive(Debug, Clone)]
pub struct WalletMobileConnectorFactory {
    pub(crate) folder_path: String,
}

impl WalletMobileConnectorFactory {
    #[frb(sync)]
    pub fn new(folder_path: String) -> Self {
        Self { folder_path }
    }
}

impl WalletConnectorFactory<WalletMobileConnector, WalletMobilePersister>
    for WalletMobileConnectorFactory
{
    fn build(self, key: String) -> WalletMobileConnector {
        let clean_key = key.replace("'", "_").replace("/", "_");
        let db_path = format!(
            "{}/proton_wallet_bdk_{}.sqlite",
            self.folder_path, clean_key
        );
        WalletMobileConnector::new(&db_path)
    }
}

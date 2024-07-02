pub use andromeda_api::wallet::ApiWalletSettings;
use flutter_rust_bridge::frb;

#[frb(mirror(ApiWalletSettings))]
#[allow(non_snake_case)]
pub struct _WalletSettings {
    pub WalletID: String,
    pub HideAccounts: u8,
    pub InvoiceDefaultDescription: Option<String>,
    pub InvoiceExpirationTime: u64,
    pub MaxChannelOpeningFee: u64,
    pub ShowWalletRecovery: Option<bool>,
}

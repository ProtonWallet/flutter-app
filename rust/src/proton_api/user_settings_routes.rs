use muon::session::Session;
use openssl::string;

use super::types::ResponseCode;


#[derive(Debug, Clone)]
struct WalletUserSettings {
    pub(crate) bitcoin_unit: String,
    pub(crate) fiat_currency_unit: String,
    pub(crate) hide_empty_used_addresses: bool,
    pub(crate) show_wallet_recovery: bool,
    pub(crate) two_factor_amount_threshold: u64,
}

struct WalletUserSettingsResponse {
    pub code: i64,
    pub(crate) settings: WalletUserSettings,
}

pub(crate) struct UserSettingsClient {
    session: Session,
}

pub(crate) trait UserSettingsRoute {
    //Get the global wallet user settings [GET] /wallet/{_version}/settings
    async fn get_walelt_user_settings(&self) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>>;
    // Update preferred Bitcoin unit
    async fn update_preferred_btc_unit(&self, symble: String) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>>;
    // Update preferred fiat currency //
    // New preferred symbol (BTC/MBTC/SATS or EUR/CHF/USD)
    async fn update_preferred_fiat_currency(&self, symble: String) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>>;
    // Update two-factor amount threshold
    async fn update_twofa_amount_threshold(&self, threshold: u64) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>>;
    // Update hide empty used addresses 
    async fn update_hide_empty_used_addresses(&self, hide: bool) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>>;

}

use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct WalletUserSettingsModel {
    pub user_id: String,
    pub bitcoin_unit: String,
    pub fiat_currency: String,
    pub hide_empty_used_addresses: u8,
    pub show_wallet_recovery: u8,
    pub two_factor_amount_threshold: f64,
    pub receive_inviter_notification: u8,
    pub receive_email_integration_notification: u8,
    pub wallet_created: u8,
    pub accept_terms_and_conditions: u8,
}

impl ModelBase for WalletUserSettingsModel {
    fn from_row(row: &Row) -> Result<Self> {
        Ok(from_row::<WalletUserSettingsModel>(row).unwrap())
    }
}

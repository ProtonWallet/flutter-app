use andromeda_api::wallet::ApiWalletData;
use chrono::Utc;
use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone, Default)]
pub struct WalletModel {
    pub id: u32,
    pub name: String,
    pub passphrase: u32,
    pub public_key: String,
    pub imported: u32,
    pub priority: u32,
    pub status: u32,
    #[serde(rename = "type")]
    pub type_: u32,
    pub create_time: u32,
    pub modify_time: u32,
    pub user_id: String,
    pub wallet_id: String,
    pub account_count: u32,
    pub balance: f64,
    pub fingerprint: Option<String>,
    pub show_wallet_recovery: u32,
    pub migration_required: u32,
    pub legacy: Option<u32>,
}

impl ModelBase for WalletModel {
    fn from_row(row: &Row) -> Result<Self> {
        Ok(from_row::<WalletModel>(row).unwrap())
    }
}

impl From<ApiWalletData> for WalletModel {
    fn from(value: ApiWalletData) -> Self {
        // Get the current time as a Unix timestamp
        let current_time = Utc::now().timestamp();
        WalletModel {
            id: 0,
            name: value.Wallet.Name,
            passphrase: value.Wallet.HasPassphrase as u32,
            public_key: value.Wallet.PublicKey.unwrap_or_default(),
            imported: value.Wallet.IsImported as u32,
            priority: value.Wallet.Priority as u32,
            status: value.Wallet.Status as u32,
            type_: value.Wallet.Type as u32,
            create_time: current_time as u32,
            modify_time: current_time as u32,
            // this need to be set manually
            user_id: String::default(),
            wallet_id: value.Wallet.ID,
            account_count: 1,
            balance: f64::default(),
            fingerprint: value.Wallet.Fingerprint,
            show_wallet_recovery: value.WalletSettings.ShowWalletRecovery.unwrap_or(false) as u32,
            migration_required: value.Wallet.MigrationRequired.unwrap_or(0) as u32,
            legacy: Some(value.Wallet.Legacy.unwrap_or(0) as u32),
        }
    }
}

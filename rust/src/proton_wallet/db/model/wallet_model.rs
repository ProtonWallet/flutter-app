use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone)]
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

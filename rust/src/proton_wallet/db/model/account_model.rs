use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AccountModel {
    pub id: u32,
    pub account_id: String,
    pub wallet_id: String,
    pub derivation_path: String,
    pub label: String,
    pub script_type: u32,
    pub create_time: u64,
    pub modify_time: u64,
    pub fiat_currency: String,
    pub priority: u32,
    pub last_used_index: u32,
    pub pool_size: u32,
}

impl ModelBase for AccountModel {
    fn from_row(row: &Row) -> Result<Self> {
        Ok(from_row::<AccountModel>(row).unwrap())
    }
}

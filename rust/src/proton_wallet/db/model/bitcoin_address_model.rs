use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct BitcoinAddressModel {
    pub id: Option<u32>,
    pub server_id: String,
    pub wallet_id: u32,
    pub account_id: u32,
    pub bitcoin_address: String,
    pub bitcoin_address_index: u32,
    pub in_email_integration_pool: u32,
    pub used: u32,
    pub server_wallet_id: String,
    pub server_account_id: String,
}

impl ModelBase for BitcoinAddressModel {
    fn from_row(row: &Row) -> Result<Self> {
        Ok(from_row::<BitcoinAddressModel>(row).unwrap())
    }
}

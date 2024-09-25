use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AddressModel {
    pub id: u32,
    pub server_id: String,
    pub email: String,
    pub server_wallet_id: String,
    pub server_account_id: String,
}

impl ModelBase for AddressModel {
    fn from_row(row: &Row) -> Result<Self> {
        Ok(from_row::<AddressModel>(row).unwrap())
    }
}

use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct TransactionModel {
    pub id: u32,
    #[serde(rename = "type")]
    pub type_: u32,
    pub label: String,
    pub external_transaction_id: String,
    pub create_time: u32,
    pub modify_time: u32,
    pub hashed_transaction_id: String,
    pub transaction_id: String,
    pub transaction_time: String,
    pub exchange_rate_id: String,
    pub server_wallet_id: String,
    pub server_account_id: String,
    pub server_id: String,
    pub sender: Option<String>,
    pub tolist: Option<String>,
    pub subject: Option<String>,
    pub body: Option<String>,
}

impl ModelBase for TransactionModel {
    fn from_row(row: &Row) -> Result<Self> {
        Ok(from_row::<TransactionModel>(row).unwrap())
    }
}

use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ExchangeRateModel {
    pub id: Option<u32>,
    pub server_id: String,
    pub bitcoin_unit: String,
    pub fiat_currency: String,
    pub sign: String,
    pub exchange_rate_time: String,
    pub exchange_rate: u32,
    pub cents: u32,
}

impl ModelBase for ExchangeRateModel {
    fn from_row(row: &Row) -> Result<Self> {
        Ok(from_row::<ExchangeRateModel>(row).unwrap())
    }
}

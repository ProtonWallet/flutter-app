use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ProtonUserKeyModel {
    pub key_id: String,
    pub user_id: String,
    pub version: u32,
    pub private_key: String,
    pub token: Option<String>,
    pub fingerprint: Option<String>,
    pub recovery_secret: Option<String>,
    pub recovery_secret_signature: Option<String>,
    pub primary: u32,
}

impl ModelBase for ProtonUserKeyModel {
    fn from_row(row: &Row) -> Result<Self> {
        Ok(from_row::<ProtonUserKeyModel>(row).unwrap())
    }
}

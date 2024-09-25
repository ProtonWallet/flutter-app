use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct NativeSessionModel {
    pub user_id: String,
    pub session_id: String,
    pub user_name: String,
    pub passphrase: String,
    pub access_token: String,
    pub refresh_token: String,
    pub scopes: Vec<String>,
}
impl ModelBase for NativeSessionModel {
    fn from_row(row: &Row) -> Result<Self> {
        Ok(from_row::<NativeSessionModel>(row).unwrap())
    }
}

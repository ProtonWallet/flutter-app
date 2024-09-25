use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ProtonUserModel {
    pub id: u32,
    pub user_id: String,
    pub name: String,
    pub used_space: u64,
    pub currency: String,
    pub credit: u32,
    pub create_time: u64,
    pub max_space: u64,
    pub max_upload: u64,
    pub role: u32,
    #[serde(rename = "private")] // Since `private` is a reserved keyword, use `rename` for clarity
    pub private: u32,
    pub subscribed: u32,
    pub services: u32,
    pub delinquent: u32,
    pub organization_private_key: Option<String>,
    pub email: Option<String>,
    pub display_name: Option<String>,
}

impl ModelBase for ProtonUserModel {
    fn from_row(row: &Row) -> Result<Self> {
        Ok(from_row::<ProtonUserModel>(row).unwrap())
    }
}

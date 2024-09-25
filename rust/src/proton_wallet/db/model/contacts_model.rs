use rusqlite::{Result, Row};
use serde::{Deserialize, Serialize};
use serde_rusqlite::from_row;

use super::model::ModelBase;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ContactsModel {
    pub id: Option<u32>,
    pub server_contact_id: String,
    pub name: String,
    pub email: String,
    pub canonical_email: String,
    pub is_proton: u32,
}
impl ModelBase for ContactsModel {
    fn from_row(row: &Row) -> Result<Self> {
        Ok(from_row::<ContactsModel>(row).unwrap())
    }
}

use crate::proton_wallet::db::model::ramp_countries_model::RampCountriesModel;
use rusqlite::{params, Connection, Result};
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Debug)]
pub struct RampCountriesDao {
    conn: Arc<Mutex<Connection>>,
}

impl RampCountriesDao {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Result<Self> {
        Ok(Self { conn })
    }
}

impl RampCountriesDao {
    pub fn insert(&self, item: &RampCountriesModel) -> Result<u32> {
        let conn = self.conn.lock().await;
    }

    pub fn get(&self, id: u32) -> Result<Option<RampCountriesModel>> {
        let conn = self.conn.lock().await;
        let mut stmt = conn.prepare("SELECT * FROM ramp_countries_table WHERE id = ?1")?;
        let result = stmt.query_row(params![id], |row| Ok(RampCountriesModel::from_row(row)?));
        Ok(result.ok())
    }

    pub fn get_all(&self) -> Result<Vec<RampCountriesModel>> {
        let conn = self.conn.lock().await;
        let mut stmt = conn.prepare("SELECT * FROM ramp_countries_table")?;
        let account_iter = stmt.query_map([], |row| Ok(RampCountriesModel::from_row(row)?))?;
        let accounts: Vec<RampCountriesModel> = account_iter.collect::<Result<_>>()?;
        Ok(accounts)
    }

    pub fn update(&self, item: &RampCountriesModel) -> Result<Option<RampCountriesModel>> {}

    pub fn delete(&self, id: u32) -> Result<()> {
        let conn = self.conn.lock().await;
        conn.execute(
            "DELETE FROM ramp_countries_table WHERE id = ?1",
            params![id],
        )?;
        Ok(())
    }
}

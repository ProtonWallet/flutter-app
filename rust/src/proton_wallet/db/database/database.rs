use async_trait::async_trait;
use log::info;
use rusqlite::{params, Connection};
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{table_names::TableName, Result};
use crate::proton_wallet::db::{error::DatabaseError, model::model::ModelBase};

#[async_trait]
pub trait BaseDatabase {
    fn new(conn: Arc<Mutex<Connection>>) -> Self
    where
        Self: Sized;

    fn conn(&self) -> &Arc<Mutex<Connection>>;

    fn table_name(&self) -> &TableName;

    async fn create_table(&self, create_table_query: &str) -> Result<usize> {
        let conn = self.conn().lock().await;
        Ok(conn.execute(create_table_query, [])?)
    }

    async fn drop_table(&self) -> Result<usize> {
        let query = format!("DROP TABLE IF EXISTS `{}`", self.table_name().as_str());
        let conn = self.conn().lock().await;
        conn.execute(&query, []).map_err(|e| e.into())
    }

    async fn add_column(&self, column_name: &str, column_type: &str) -> Result<usize> {
        let query = format!(
            "ALTER TABLE {} ADD COLUMN {} {}",
            self.table_name().as_str(),
            column_name,
            column_type
        );

        let conn = self.conn().lock().await;
        conn.execute(&query, []).map_err(|e| e.into())
    }

    async fn add_index(&self, column_name: &str) -> Result<usize> {
        let query = format!(
            "CREATE INDEX IF NOT EXISTS idx_{} ON {}({})",
            column_name,
            self.table_name().as_str(),
            column_name
        );

        let conn = self.conn().lock().await;
        conn.execute(&query, []).map_err(|e| e.into())
    }

    async fn drop_column(&self, column_name: &str) -> Result<usize> {
        let query = format!(
            "ALTER TABLE {} DROP COLUMN {}",
            self.table_name().as_str(),
            column_name
        );
        let conn = self.conn().lock().await;
        conn.execute(&query, []).map_err(|e| e.into())
    }

    async fn print_table_schema(&self) -> Result<()> {
        let query = format!("PRAGMA table_info({})", self.table_name().as_str());
        let conn = self.conn().lock().await;
        let mut stmt = conn.prepare(&query)?;
        let schema = stmt.query_map([], |row| {
            Ok((
                row.get::<_, String>(1)?,
                row.get::<_, String>(2)?,
                row.get::<_, i32>(3)?,
                row.get::<_, Option<String>>(4)?,
                row.get::<_, i32>(5)?,
            ))
        })?;

        for column in schema {
            let (name, col_type, not_null, dflt_value, pk) = column?;
            info!(
                "Column: {}\nType: {}\nNot Null: {}\nDefault Value: {:?}\nPrimary Key: {}\n---",
                name, col_type, not_null, dflt_value, pk
            );
        }

        Ok(())
    }

    async fn table_exists(&self, table_name: &str) -> Result<bool> {
        let conn = self.conn().lock().await;
        let mut stmt =
            conn.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name=?1")?;
        let mut rows = stmt.query([table_name])?;

        Ok(rows.next()?.is_some())
    }

    async fn column_exists(&self, column_name: &str) -> Result<bool> {
        let conn = self.conn().lock().await;
        let mut stmt = conn.prepare(&format!(
            "PRAGMA table_info(`{}`);",
            self.table_name().as_str()
        ))?;
        let mut rows = stmt.query([])?;
        while let Some(row) = rows.next()? {
            let col_name: String = row.get(1)?;
            if col_name == column_name {
                return Ok(true);
            }
        }

        Ok(false)
    }

    // pre build get all generic function
    /// Notes: should be sql injection safe. table_name is a const string
    async fn get_all<T: ModelBase>(&self) -> Result<Vec<T>> {
        let conn = self.conn().lock().await;
        let mut stmt = conn.prepare(&format!("SELECT * FROM `{}`", self.table_name().as_str()))?;
        let iter = stmt.query_map([], |row| T::from_row(row))?;
        let items: Vec<T> = iter.collect::<rusqlite::Result<_>>()?;
        Ok(items)
    }

    async fn get_by_id<T: ModelBase>(&self, id: u32) -> Result<Option<T>> {
        let conn = self.conn().lock().await;
        let mut stmt = conn.prepare(&format!(
            "SELECT * FROM `{}` WHERE id = ?1",
            self.table_name().as_str()
        ))?;
        let result = stmt.query_row(params![id], |row| T::from_row(row));
        Ok(result.ok())
    }

    async fn get_by_column_id<T: ModelBase>(
        &self,
        column_name: &str,
        value: &str,
    ) -> Result<Option<T>> {
        let exsit = self.column_exists(column_name).await?;
        if !exsit {
            return Err(DatabaseError::ColumnNotFound(column_name.to_string()));
        }
        let conn = self.conn().lock().await;
        let mut stmt = conn.prepare(&format!(
            "SELECT * FROM `{}` WHERE `{}` = ?1",
            self.table_name().as_str(),
            column_name
        ))?;
        let result = stmt.query_row(params![value], |row| T::from_row(row));
        Ok(result.ok())
    }

    async fn get_all_by_column_id<T: ModelBase>(
        &self,
        column_name: &str,
        value: &str,
    ) -> Result<Vec<T>> {
        let exsit = self.column_exists(column_name).await?;
        if !exsit {
            return Err(DatabaseError::ColumnNotFound(column_name.to_string()));
        }
        let conn = self.conn().lock().await;
        let mut stmt = conn.prepare(&format!(
            "SELECT * FROM `{}` WHERE `{}` = ?1",
            self.table_name().as_str(),
            column_name
        ))?;
        let account_iter = stmt.query_map([value], |row| T::from_row(row))?;
        let accounts: Vec<T> = account_iter.collect::<rusqlite::Result<_>>()?;
        Ok(accounts)
    }

    async fn delete_by_id(&self, id: u32) -> Result<()> {
        let conn = self.conn().lock().await;
        conn.execute(
            &format!("DELETE FROM `{}` WHERE id = ?1", self.table_name().as_str()),
            params![id],
        )?;
        Ok(())
    }

    async fn delete_by_column_id(&self, column_name: &str, value: &str) -> Result<()> {
        let exsit = self.column_exists(column_name).await?;
        if !exsit {
            return Err(DatabaseError::ColumnNotFound(column_name.to_string()));
        }
        let conn = self.conn().lock().await;
        conn.execute(
            &format!(
                "DELETE FROM `{}` WHERE `{}` = ?1",
                self.table_name().as_str(),
                column_name
            ),
            params![value],
        )?;
        Ok(())
    }

    // fn is_valid_table_name(&self, table_name: &str) -> bool {
    //     let valid_table_name = regex::Regex::new(r"^[a-zA-Z0-9_]+$").unwrap();
    //     valid_table_name.is_match(table_name)
    // }
    // fn get_exception(&self) -> String {
    //     format!("Invalid table name {}", self.table_name())
    // }
}

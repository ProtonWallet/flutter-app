use rusqlite::{Connection, Result};
use std::sync::Arc;

use super::error::DatabaseError;

pub trait BaseDatabase {
    fn new(conn: Arc<Connection>, table_name: &str) -> Self
    where
        Self: Sized;

    fn conn(&self) -> &Arc<Connection>;

    fn table_name(&self) -> &str;

    fn create_table(&self, create_table_query: &str) -> Result<usize, DatabaseError> {
        Ok(self.conn().execute(create_table_query, [])?)
    }

    fn drop_table(&self) -> Result<usize, DatabaseError> {
        let query = format!("DROP TABLE IF EXISTS `{}`", self.table_name());
        self.conn().execute(&query, []).map_err(|e| e.into())
    }

    fn add_column(&self, column_name: &str, column_type: &str) -> Result<usize, DatabaseError> {
        let query = format!(
            "ALTER TABLE {} ADD COLUMN {} {}",
            self.table_name(),
            column_name,
            column_type
        );
        self.conn().execute(&query, []).map_err(|e| e.into())
    }

    fn add_index(&self, column_name: &str) -> Result<usize, DatabaseError> {
        let query = format!(
            "CREATE INDEX IF NOT EXISTS idx_{} ON {}({})",
            column_name,
            self.table_name(),
            column_name
        );
        self.conn().execute(&query, []).map_err(|e| e.into())
    }

    fn drop_column(&self, column_name: &str) -> Result<usize, DatabaseError> {
        let query = format!(
            "ALTER TABLE {} DROP COLUMN {}",
            self.table_name(),
            column_name
        );
        self.conn().execute(&query, []).map_err(|e| e.into())
    }

    fn print_table_schema(&self) -> Result<()> {
        let query = format!("PRAGMA table_info({})", self.table_name());
        let mut stmt = self.conn().prepare(&query)?;
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
            println!(
                "Column: {}\nType: {}\nNot Null: {}\nDefault Value: {:?}\nPrimary Key: {}\n---",
                name, col_type, not_null, dflt_value, pk
            );
        }

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

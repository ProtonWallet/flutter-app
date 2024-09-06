use log::error;
use rusqlite::Connection;
use std::sync::Arc;

use super::{database::BaseDatabase, error::DatabaseError};

pub struct AccountDatabase {
    conn: Arc<Connection>,
    table_name: String,
}

impl BaseDatabase for AccountDatabase {
    fn new(conn: Arc<Connection>, table_name: &str) -> Self {
        AccountDatabase {
            conn,
            table_name: table_name.to_string(),
        }
    }

    fn conn(&self) -> &Arc<Connection> {
        &self.conn
    }

    fn table_name(&self) -> &str {
        &self.table_name
    }
}

impl AccountDatabase {
    // You can add specific migration methods here
    fn migration_0(&self) -> Result<(), DatabaseError> {
        self.drop_table()?;
        self.create_table(
            r#"
            CREATE TABLE IF NOT EXISTS `account_table` (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                accountID TEXT,
                walletID TEXT,
                derivationPath TEXT,
                label BLOB,
                scriptType INTEGER,
                createTime INTEGER,
                modifyTime INTEGER,
                fiatCurrency TEXT,
                priority INTEGER,
                lastUsedIndex INTEGER,
                UNIQUE (walletID, derivationPath)
            )
            "#,
        )?;
        self.add_index("walletID")?;
        self.add_index("accountID")?;
        Ok(())
    }

    fn migration_1(&self) -> Result<(), DatabaseError> {
        if let Err(e) = self.drop_column("poolSize") {
            error!("Failed to drop column poolSize: {:?}", e);
        }
        self.add_column("poolSize", "INTEGER DEFAULT 10")?;
        Ok(())
    }
}

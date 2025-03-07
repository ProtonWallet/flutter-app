use andromeda_bitcoin::{
    storage::{ChangeSet, Storage},
    Connection,
};
use std::sync::Arc;
use tokio::sync::Mutex;
use tracing::info;

#[derive(Clone, Debug)]
pub(crate) struct WalletMobilePersister {
    store: Arc<Mutex<Connection>>,
}

impl WalletMobilePersister {
    pub fn new(db_path: &str) -> Self {
        info!(
            "Initializing WalletMobilePersister with db_path: {}",
            db_path
        );
        let conn = Connection::open(db_path).expect("Failed to open database connection");
        Self {
            store: Arc::new(Mutex::new(conn)),
        }
    }
}

impl Storage for WalletMobilePersister {
    fn initialize(&self) -> std::result::Result<ChangeSet, andromeda_bitcoin::error::Error> {
        let mut conn = self
            .store
            .try_lock()
            .expect("Failed to lock database connection");
        let db_tx = conn.transaction()?;
        ChangeSet::init_sqlite_tables(&db_tx)?;
        let changeset = ChangeSet::from_sqlite(&db_tx)?;
        db_tx.commit()?;
        Ok(changeset)
    }

    fn persist(&self, changeset: &ChangeSet) -> Result<(), andromeda_bitcoin::error::Error> {
        let mut conn = self
            .store
            .try_lock()
            .expect("Failed to lock database connection");
        let db_tx = conn.transaction()?;
        changeset.persist_to_sqlite(&db_tx)?;
        Ok(db_tx.commit()?)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use andromeda_bitcoin::storage::ChangeSet;

    #[test]
    fn test_wallet_mobile_persister_initialize() {
        let db_path = "./proton_wallet_bdk_test.sqlite";
        let mobile_persister = WalletMobilePersister::new(db_path);
        let result = mobile_persister.initialize();
        assert!(result.is_ok(), "Expected initialization to pass");
        let changeset = ChangeSet::default();
        let result = mobile_persister.persist(&changeset);
        assert!(result.is_ok(), "Expected persisting to pass");
    }
}

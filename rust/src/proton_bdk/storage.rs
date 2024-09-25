use andromeda_bitcoin::{
    storage::{ChangeSet, WalletPersister, WalletPersisterConnector},
    Connection,
};
use log::info;
use rusqlite::Error;
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Clone, Debug)]
pub(crate) struct WalletMobilePersister {
    store: Arc<Mutex<Connection>>,
}

impl WalletMobilePersister {
    fn new(db_path: String) -> Self {
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

impl WalletPersister for WalletMobilePersister {
    type Error = Error;

    fn initialize(persister: &mut Self) -> Result<ChangeSet, Self::Error> {
        let mut conn = persister
            .store
            .try_lock()
            .expect("Failed to lock database connection");
        let db_tx = conn.transaction()?;
        ChangeSet::init_sqlite_tables(&db_tx)?;
        let changeset = ChangeSet::from_sqlite(&db_tx)?;
        db_tx.commit()?;
        Ok(changeset)
    }

    fn persist(persister: &mut Self, changeset: &ChangeSet) -> Result<(), Self::Error> {
        let mut conn = persister
            .store
            .try_lock()
            .expect("Failed to lock database connection");
        let db_tx = conn.transaction()?;
        changeset.persist_to_sqlite(&db_tx)?;
        db_tx.commit()
    }
}

#[derive(Debug, Clone)]
pub struct WalletMobileConnector {
    store: WalletMobilePersister,
}

impl WalletMobileConnector {
    pub fn new(db_path: String) -> Self {
        Self {
            store: WalletMobilePersister::new(db_path),
        }
    }
}

impl WalletPersisterConnector<WalletMobilePersister> for WalletMobileConnector {
    fn connect(&self) -> WalletMobilePersister {
        self.store.clone()
    }
}

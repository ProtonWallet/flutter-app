use andromeda_bitcoin::{
    storage::{ChangeSet, WalletPersister, WalletPersisterConnector},
    Connection,
};
use log::info;
use rusqlite::Error;
use std::sync::Arc;
use tokio::sync::Mutex;
// use lazy_static::lazy_static;
// lazy_static! {
//     static ref WALLET_STORAGE: Arc<Mutex<HashMap<String, String>>> =
//         Arc::new(Mutex::new(HashMap::new()));
// }

#[derive(Clone, Debug)]
pub(crate) struct WalletMobilePersister {
    store: Arc<Mutex<Connection>>,
    // changeset_key: String,
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
        // Self {
        //     changeset_key: db_path,
        // }
    }

    // fn get(&self) -> Option<ChangeSet> {
    //     debug!(
    //         "BDK Debug: Getting changeset from storage key {}",
    //         self.changeset_key
    //     );
    //     let storage = WALLET_STORAGE.try_lock().unwrap();
    //     let serialized = storage.get(&self.changeset_key.clone());
    //     if let Some(serialized) = serialized {
    //         return serde_json::from_str(&serialized).ok();
    //     }
    //     None
    // }

    // fn set(&self, changeset: ChangeSet) -> Result<(), serde_json::Error> {
    //     debug!(
    //         "BDK Debug: Setting changeset from storage key {}",
    //         self.changeset_key
    //     );
    //     let mut storage = WALLET_STORAGE.try_lock().unwrap();
    //     let serialized = serde_json::to_string(&changeset)?;
    //     storage.insert(self.changeset_key.clone(), serialized);
    //     Ok(())
    // }
}

impl WalletPersister for WalletMobilePersister {
    // type Error = serde_json::Error;
    type Error = Error;

    fn initialize(persister: &mut Self) -> Result<ChangeSet, Self::Error> {
        // Ok(persister.get().unwrap_or_default())
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
        // let mut prev_changeset = persister.get().unwrap_or_default();
        // prev_changeset.merge(changeset.clone());
        // persister.set(prev_changeset)
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

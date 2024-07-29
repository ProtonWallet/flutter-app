// storage.rs
use flutter_rust_bridge::frb;
use std::sync::{Arc, Mutex};

// storage.rs
use andromeda_bitcoin::{
    error::Error,
    storage::{ChangeSet, WalletStore, WalletStoreFactory},
    Append, ConfirmationTimeHeightAnchor, KeychainKind,
};
use log::info;

use bdk_sqlite::{rusqlite::Connection, Store};

#[derive(Clone, Copy)]
pub struct OnchainStoreFactory {
    pub folder_path: &'static str,
}

impl OnchainStoreFactory {
    #[frb(sync)]
    pub fn new(folder_path: String) -> Self {
        // Leak the memory of the String to get a &'static str will change to clone
        let folder_path_static: &'static str = Box::leak(folder_path.into_boxed_str());
        Self {
            folder_path: folder_path_static,
        }
    }
}

impl WalletStoreFactory<OnchainStore> for OnchainStoreFactory {
    fn build(self, key: String) -> OnchainStore {
        let clean_key = key.replace("'", "_").replace("/", "_");
        let db_name = format!(
            "{}/proton_wallet_bdk_{}.sqlite",
            self.folder_path, clean_key
        );
        OnchainStore::new(db_name)
    }
}
use lazy_static::lazy_static;
lazy_static! {
    pub static ref STATIC_CHANGESET: Arc<Mutex<Option<String>>> = Arc::new(Mutex::new(None));
}

#[derive(Clone, Debug)]
pub(crate) struct OnchainStore {
    store: Arc<Mutex<Store<KeychainKind, ConfirmationTimeHeightAnchor>>>,
}

impl OnchainStore {
    fn new(db_path: String) -> Self {
        info!("OnchainStore::new db_path: {} ", db_path);
        let conn = Connection::open(db_path.clone()).unwrap();
        let store: Store<KeychainKind, ConfirmationTimeHeightAnchor> = Store::new(conn).unwrap();
        Self {
            store: Arc::new(Mutex::new(store)),
        }
    }
}

impl WalletStore for OnchainStore {
    fn read(&self) -> Result<Option<ChangeSet>, Error> {
        let mut db_guard = self.store.lock().unwrap();
        let changeset = db_guard.read().unwrap();

        if let Some(value) = changeset.clone() {
            if value.is_empty() {
                println!("read Changeset is empty")
            } else {
                println!("read Changeset is not empty")
            }
        } else {
            println!("read Changeset is None");
        }
        Ok(changeset)

        // let changeset = STATIC_CHANGESET.lock().unwrap();
        // match changeset.clone() {
        //     Some(serialized) => {
        //         let deserialized: ChangeSet = serde_json::from_str(&serialized).unwrap();
        //         Ok(Some(deserialized))
        //     }
        //     None => Ok(None),
        // }
    }

    fn write(&self, changeset: &ChangeSet) -> Result<(), Error> {
        let mut db_guard = self.store.lock().unwrap();
        let result = db_guard.write(&changeset.clone());
        if result.is_err() {
            info!("Persisted changeset error: {:?}", result);
        }

        let value = changeset.clone();
        if value.is_empty() {
            println!("write Changeset is empty")
        } else {
            println!("write Changeset is not empty")
        }

        // let mut prev_changeset = self.read()?.clone().unwrap_or_default();
        // prev_changeset.append(changeset.clone());
        // let serialized = serde_json::to_string(&prev_changeset).unwrap();
        // *STATIC_CHANGESET.lock().unwrap() = Some(serialized.clone());

        // println!("Persisted changeset: {:?}", serialized);

        Ok(())
    }

    fn clear(&self) -> Result<(), Error> {
        Ok(())
    }
}

// #[derive(Clone, Debug)]
// pub(crate) struct MemoryOnchainStore {
//     changeset: RefCell<Option<ChangeSet>>,
// }

// impl MemoryOnchainStore {
//     fn new() -> Self {
//         Self {
//             changeset: RefCell::new(None),
//         }
//     }
// }

// impl WalletStore for MemoryOnchainStore {
//     fn read(&self) -> Result<Option<ChangeSet>, Error> {
//         Ok(self.changeset.borrow().clone())
//     }

//     fn write(&self, changeset: &ChangeSet) -> Result<(), Error> {
//         *self.changeset.borrow_mut() = Some(changeset.clone());
//         Ok(())
//     }
// }

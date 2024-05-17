use andromeda_bitcoin::account::Account as CommonBdkAccount;
use andromeda_bitcoin::BdkAnyDatabase;

use lazy_static::lazy_static;
use std::collections::hash_map::DefaultHasher;
use std::collections::HashMap;
use std::hash::Hash;
use std::hash::Hasher;
use std::sync::RwLock;
use std::sync::{Arc, Mutex, MutexGuard};

use super::balance::Balance;
use super::error::Error;

lazy_static! {
    static ref WALLET: RwLock<HashMap<String, Arc<Account>>> = RwLock::new(HashMap::new());
}

fn persist_wallet(id: String, wallet: Account) {
    let mut wallet_lock = WALLET.write().unwrap();
    wallet_lock.insert(id, Arc::new(wallet));
}

pub fn default_hasher<T>(obj: T) -> u64
where
    T: Hash,
{
    let mut hasher = DefaultHasher::new();
    obj.hash(&mut hasher);
    hasher.finish()
}
/// A Bitcoin wallet. rust common named it as Account.
///
/// The Wallet acts as a way of coherently interfacing with output descriptors and related transactions. Its main components are:
///     1. Output descriptors from which it can derive addresses.
///     2. A Database where it tracks transactions and utxos related to the descriptors.
///     3. Signers that can contribute signatures to addresses instantiated from the descriptors.
#[derive(Debug)]
pub struct Account {
    pub account_mutex: Mutex<CommonBdkAccount<BdkAnyDatabase>>,
}
impl Account {
    pub fn retrieve_wallet(id: String) -> Arc<Account> {
        let wallet_lock = WALLET.read().unwrap();
        wallet_lock.get(id.as_str()).unwrap().clone()
    }

    pub fn get_inner(&self) -> MutexGuard<CommonBdkAccount<BdkAnyDatabase>> {
        self.account_mutex.lock().expect("account")
    }

    pub fn get_balance(&self) -> Result<Balance, Error> {
        let result = self.get_inner().get_balance();
        match result {
            Ok(balance) => Ok(balance),
            Err(e) => Err(Error::from(e)),
        }
    }
}

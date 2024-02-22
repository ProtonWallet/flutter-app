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

    // pub fn new_wallet(
    //     descriptor: String,
    //     change_descriptor: Option<String>,
    //     network: bitcoin::Network,
    //     database_config: DatabaseConfig,
    // ) -> Result<String, BdkError> {
    //     let database: AnyDatabase = AnyDatabase::from_config(&database_config.into()).unwrap();
    //     let bdk_wallet =
    //         BdkWallet::new(&descriptor, change_descriptor.as_ref(), network, database).unwrap();
    //     let wallet_mutex = Mutex::new(bdk_wallet);

    //     let wallet = Wallet { wallet_mutex };

    //     let id = default_hasher(&descriptor).to_hex();
    //     persist_wallet(id.clone(), wallet);
    //     Ok(id)
    // }

    // pub(crate) fn get_wallet(&self) -> MutexGuard<BdkWallet<AnyDatabase>> {
    //     self.wallet_mutex.lock().expect("wallet")
    // }
    // pub fn sync(&self, blockchain: &Blockchain, progress: Option<Box<dyn Progress>>) {
    //     let bdk_sync_option: SyncOptions = if let Some(p) = progress {
    //         SyncOptions {
    //             progress: Some(Box::new(ProgressHolder { progress: p })
    //                 as Box<(dyn bdk::blockchain::Progress + 'static)>),
    //         }
    //     } else {
    //         SyncOptions { progress: None }
    //     };
    //     let blockchain = blockchain.get_blockchain();
    //     self.get_wallet()
    //         .sync(blockchain.deref(), bdk_sync_option)
    //         .unwrap()
    // }
    // /// Return the balance, meaning the sum of this wallet’s unspent outputs’ values. Note that this method only operates
    // /// on the internal database, which first needs to be Wallet.sync manually.
    // pub fn get_balance(&self) -> Result<Balance, BdkError> {
    //     self.get_wallet().get_balance().map(|b| b.into())
    // }
    // pub(crate) fn is_mine(&self, script: Script) -> Result<bool, BdkError> {
    //     self.get_wallet().is_mine(&script)
    // }
    // // Return a derived address using the internal (change) descriptor.
    // ///
    // /// If the wallet doesn't have an internal descriptor it will use the external descriptor.
    // ///
    // /// see [`AddressIndex`] for available address index selection strategies. If none of the keys
    // /// in the descriptor are derivable (i.e. does not end with /*) then the same address will always
    // /// be returned for any [`AddressIndex`].
    // pub(crate) fn get_internal_address(
    //     &self,
    //     address_index: AddressIndex,
    // ) -> Result<AddressInfo, BdkError> {
    //     self.get_wallet()
    //         .get_internal_address(address_index.into())
    //         .map(AddressInfo::from)
    // }
    // pub fn get_address(&self, address_index: AddressIndex) -> Result<AddressInfo, BdkError> {
    //     self.get_wallet()
    //         .get_address(address_index.into())
    //         .map(AddressInfo::from)
    // }

    // /// Return the list of transactions made and received by the wallet. Note that this method only operate on the internal database, which first needs to be [Wallet.sync] manually.
    // pub fn list_transactions(
    //     &self,
    //     include_raw: bool,
    // ) -> Result<Vec<TransactionDetails>, BdkError> {
    //     let transaction_details = self.get_wallet().list_transactions(include_raw).unwrap();
    //     Ok(transaction_details
    //         .iter()
    //         .map(TransactionDetails::from)
    //         .collect())
    // }
    // // Return the list of unspent outputs of this wallet. Note that this method only operates on the internal database,
    // // which first needs to be Wallet.sync manually.
    // pub fn list_unspent(&self) -> Result<Vec<LocalUtxo>, BdkError> {
    //     let unspents = self.get_wallet().list_unspent()?;
    //     Ok(unspents.into_iter().map(LocalUtxo::from).collect())
    // }
    // pub(crate) fn sign(
    //     &self,
    //     psbt: &PartiallySignedTransaction,
    //     sign_options: Option<SignOptions>,
    // ) -> Result<bool, BdkError> {
    //     let mut psbt = psbt.internal.lock().unwrap();
    //     self.get_wallet().sign(
    //         &mut psbt,
    //         sign_options.map(SignOptions::into).unwrap_or_default(),
    //     )
    // }
    // /// Returns the descriptor used to create addresses for a particular `keychain`.
    // pub fn get_descriptor_for_keychain(
    //     &self,
    //     keychain: KeychainKind,
    // ) -> Result<BdkDescriptor, BdkError> {
    //     let wallet = self.get_wallet();
    //     Ok(BdkDescriptor {
    //         extended_descriptor: wallet
    //             .get_descriptor_for_keychain(keychain.into())
    //             .to_owned(),
    //         key_map: KeyMap::new(),
    //     })
    // }
    // pub fn get_psbt_input(
    //     &self,
    //     utxo: LocalUtxo,
    //     only_witness_utxo: bool,
    //     psbt_sighash_type: Option<PsbtSigHashType>,
    // ) -> Result<Input, BdkError> {
    //     self.get_wallet().get_psbt_input(
    //         utxo.into(),
    //         psbt_sighash_type.map(|x| PsbtSighashType::from_u32(x.inner)),
    //         only_witness_utxo,
    //     )
    // }
}

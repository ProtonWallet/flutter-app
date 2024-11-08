use andromeda_api::{proton_users::ProtonUserKey, wallet::ApiWalletKey};
use std::{future::Future, pin::Pin};

use crate::proton_wallet::storage::wallet_mnemonic_ext::MnemonicData;

// Type alias for a future that returns a value
pub type DartFnFuture<T> = Pin<Box<dyn Future<Output = T> + Send + 'static>>;

// Type alias for the callback that fetches wallet keys
pub type WalletKeysFetcher = dyn Fn() -> DartFnFuture<Vec<ApiWalletKey>> + Send + Sync;

// Type alias for the callback that sets (saves) wallet keys
pub type WalletKeysSeter = dyn Fn(Vec<ApiWalletKey>) -> DartFnFuture<()> + Send + Sync;

// Type alias for the callback that fetches a list of `ProtonUserKey`
pub type UserKeysFetcher = dyn Fn(String) -> DartFnFuture<Vec<ProtonUserKey>> + Send + Sync;

// Type alias for the callback that fetches a single `ProtonUserKey`
pub type UserKeyFetcher = dyn Fn(String) -> DartFnFuture<ProtonUserKey> + Send + Sync;

// Type alias for the callback that get user key `Passphrase`
pub type UserKeyPassphraseFetcher = dyn Fn(String) -> DartFnFuture<String> + Send + Sync;

// Type alias for the callback that fetches wallet Mnemonic
pub type WalletMnemonicFetcher = dyn Fn() -> DartFnFuture<Vec<MnemonicData>> + Send + Sync;

// Type alias for the callback that sets (saves) wallet Mnemonic
pub type WalletMnemonicSeter = dyn Fn(Vec<MnemonicData>) -> DartFnFuture<()> + Send + Sync;

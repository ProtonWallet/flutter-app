use proton_crypto::CryptoError;

use crate::proton_wallet::{
    crypto::errors::WalletCryptoError, db::error::DatabaseError, storage::error::WalletStorageError,
};

#[derive(Debug, thiserror::Error)]
pub enum ProviderError {
    #[error("Andromeda api error: {0}")]
    AndromedaApi(#[from] andromeda_api::error::Error),

    #[error("Wallet storage error: {0}")]
    WalletStorage(#[from] WalletStorageError),

    #[error("Wallet key is empty")]
    WalletKeyEmpty,

    #[error("Wallet key is not found")]
    WalletKeyNotFound,

    #[error("Wallet crypto error: {0}")]
    WalletCrypto(#[from] WalletCryptoError),

    #[error("Wallet database error: {0}")]
    Database(#[from] DatabaseError),

    #[error("User key not found")]
    NoUserKeysFound,

    #[error("Wallet key not found")]
    NoWalletKeysFound,

    #[error("Wallet mnemonic not found")]
    NoMnemonicFound,

    #[error("Wallet mnemonic not found")]
    NoWalletMnemonicFound,

    #[error("Accounts full (maximum account size = {0})")]
    ReachedMaxAccountSize(usize),

    #[error("Crypto Srp error: {0}")]
    Srp(#[from] CryptoError),
}

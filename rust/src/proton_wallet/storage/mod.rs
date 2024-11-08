pub mod address_key_ext;
pub mod error;
pub mod user_key;
pub mod user_key_ext;
pub mod wallet_key;
pub mod wallet_mnemonic;
pub mod wallet_mnemonic_ext;

type Result<T, E = error::WalletStorageError> = std::result::Result<T, E>;

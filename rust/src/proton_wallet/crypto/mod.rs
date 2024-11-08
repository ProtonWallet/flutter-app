pub mod binary;
pub mod errors;
pub mod label;
pub mod message;
pub mod mnemonic;
pub mod mnemonic_legacy;
pub mod private_key;
pub mod public_key;
pub mod srp;
pub mod transaction_id;
pub mod transaction_label;
pub mod wallet_account_label;
pub mod wallet_key;
pub mod wallet_key_provider;
pub mod wallet_message;
pub mod wallet_name;

type Result<T, E = errors::WalletCryptoError> = std::result::Result<T, E>;

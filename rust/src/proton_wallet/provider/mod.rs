pub mod account;
pub mod address;
pub mod bitcoin_address;
pub mod contacts;
pub mod error;
pub mod exchange_rate;
pub mod proton_auth;
pub mod proton_user;
pub mod proton_user_key;
#[allow(clippy::module_inception)]
pub mod provider;
pub mod transaction;
pub mod user_keys;
pub mod wallet;
pub mod wallet_keys;
pub mod wallet_mnemonic;
pub mod wallet_name;
pub mod wallet_user_settings;
pub mod proton_auth_model;

pub type Result<T, E = error::ProviderError> = std::result::Result<T, E>;

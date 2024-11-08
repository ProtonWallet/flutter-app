pub mod account;
pub mod address;
pub mod bitcoin_address;
pub mod contacts;
#[allow(clippy::module_inception)]
pub mod database;
pub mod exchange_rate;
pub mod migration;
pub mod migration_container;
pub mod proton_address_key;
pub mod proton_user;
pub mod proton_user_key;
pub mod table_names;
pub mod transaction;
pub mod wallet;
pub mod wallet_user_settings;

type Result<T> = super::Result<T>;

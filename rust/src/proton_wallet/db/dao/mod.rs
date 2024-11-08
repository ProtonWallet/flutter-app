pub mod account_dao;
pub mod address_dao;
pub mod bitcoin_address_dao;
pub mod contacts_dao;
#[allow(clippy::module_inception)]
pub mod dao;
pub mod exchange_rate_dao;
pub mod proton_user_dao;
pub mod proton_user_key_dao;
pub mod transaction_dao;
pub mod wallet_dao;
pub mod wallet_user_settings_dao;

type Result<T> = super::Result<T>;

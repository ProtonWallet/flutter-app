pub mod backup_mnemonic;
pub mod buy;
pub mod error;
pub mod proton_recovery;
pub mod proton_settings;
pub mod settings;
pub mod wallet;

pub type Result<T, E = error::FeaturesError> = std::result::Result<T, E>;

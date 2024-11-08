use crate::proton_wallet::{crypto::errors::WalletCryptoError, provider::error::ProviderError};

#[derive(Debug, thiserror::Error)]
pub enum FeaturesError {
    #[error("Andromeda api error: {0}")]
    AndromedaApi(#[from] andromeda_api::error::Error),

    #[error("Wallet crypto error: {0}")]
    WalletCrypto(#[from] WalletCryptoError),

    #[error("Wallet provider error: {0}")]
    Provider(#[from] ProviderError),

    #[error("Invalid srp server proofs")]
    InvalidSrpServerProofs,

    #[error("Andromeda bitcoin error: {0}")]
    AndromedaBitcoin(#[from] andromeda_bitcoin::error::Error),

    #[error("No unlocked user key found")]
    NoUnlockedUserKeyFound,

    #[error("Unlocked user key partially")]
    UnlockedUserKeyPartially,

    #[error("Lock sensitive settings error code: {0}")]
    LockSensitiveSettings(u32),
}

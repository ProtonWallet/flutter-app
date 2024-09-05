use crate::proton_wallet::crypto::errors::WalletCryptoError;

#[derive(Debug, thiserror::Error)]
pub enum FeaturesError {
    #[error("Andromeda api error: {0}")]
    AndromedaApi(#[from] andromeda_api::error::Error),

    #[error("Wallet crypto error: {0}")]
    WalletCrypto(#[from] WalletCryptoError),
}

#[derive(Debug, thiserror::Error, PartialEq, Eq)]
pub enum WalletStorageError {
    #[error("Wallet key store callback is not set")]
    CallbackNotSet,
}
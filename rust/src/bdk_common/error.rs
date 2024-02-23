
#[derive(Debug)]
pub enum Error {
    AccountNotFound,
    BdkError(String),
    Bip32Error(String),
    Bip39Error(String),
    CannotBroadcastTransaction,
    CannotComputeTxFees,
    CannotGetFeeEstimation,
    CannotCreateAddressFromScript,
    CannotGetAddressFromScript,
    DerivationError,
    DescriptorError(String),
    InvalidAccountIndex,
    InvalidAddress,
    InvalidData,
    InvalidDescriptor,
    InvalidDerivationPath,
    InvalidNetwork,
    InvalidTxId,
    InvalidScriptType,
    InvalidSecretKey,
    InvalidMnemonic,
    LoadError,
    SyncError,
    TransactionNotFound,
}
impl From<andromeda_bitcoin::error::Error> for Error {
    fn from(value: andromeda_bitcoin::error::Error) -> Self {
        match value {
            andromeda_bitcoin::error::Error::AccountNotFound => Error::AccountNotFound,
            andromeda_bitcoin::error::Error::BdkError(e) => Error::BdkError(e.to_string()),
            andromeda_bitcoin::error::Error::Bip32Error(e) => Error::Bip32Error(e.to_string()),
            andromeda_bitcoin::error::Error::Bip39Error(_) => Error::Bip39Error("".to_string()),
            andromeda_bitcoin::error::Error::CannotBroadcastTransaction => Error::CannotBroadcastTransaction,
            andromeda_bitcoin::error::Error::CannotComputeTxFees => Error::CannotComputeTxFees,
            andromeda_bitcoin::error::Error::CannotGetFeeEstimation => Error::CannotGetFeeEstimation,
            andromeda_bitcoin::error::Error::CannotCreateAddressFromScript => Error::CannotCreateAddressFromScript,
            andromeda_bitcoin::error::Error::CannotGetAddressFromScript => Error::CannotGetAddressFromScript,
            andromeda_bitcoin::error::Error::DerivationError => Error::DerivationError,
            andromeda_bitcoin::error::Error::DescriptorError(e) => Error::DescriptorError(e.to_string()),
            andromeda_bitcoin::error::Error::InvalidAccountIndex => Error::InvalidAccountIndex,
            andromeda_bitcoin::error::Error::InvalidAddress => Error::InvalidAddress,
            andromeda_bitcoin::error::Error::InvalidData => Error::InvalidData,
            andromeda_bitcoin::error::Error::InvalidDescriptor => Error::InvalidDescriptor,
            andromeda_bitcoin::error::Error::InvalidDerivationPath => Error::InvalidDerivationPath,
            andromeda_bitcoin::error::Error::InvalidNetwork => Error::InvalidNetwork,
            andromeda_bitcoin::error::Error::InvalidTxId => Error::InvalidTxId,
            andromeda_bitcoin::error::Error::InvalidScriptType => Error::InvalidScriptType,
            andromeda_bitcoin::error::Error::InvalidSecretKey => Error::InvalidSecretKey,
            andromeda_bitcoin::error::Error::InvalidMnemonic => Error::InvalidMnemonic,
            andromeda_bitcoin::error::Error::LoadError => Error::LoadError,
            andromeda_bitcoin::error::Error::SyncError => Error::SyncError,
            andromeda_bitcoin::error::Error::TransactionNotFound => Error::TransactionNotFound,
        }
    }
}

impl From<bdk::Error> for Error {
    fn from(value: bdk::Error) -> Self {
       Error::BdkError(value.to_string())
    }
}

// impl From<bdk::miniscript::Error> for Error {
//     fn from(value: bdk::miniscript::Error) -> Self {
//         Error::Miniscript(value.to_string())
//     }
// }
// impl From<DescriptorKeyParseError> for Error {
//     fn from(value: DescriptorKeyParseError) -> Self {
//         Error::Descriptor(value.to_string())
//     }
// }

// impl From<bdk::bitcoin::locktime::Error> for Error {
//     fn from(value: bdk::bitcoin::locktime::Error) -> Self {
//         Error::Miniscript(value.to_string())
//     }
// }

// impl From<serde_json::Error> for Error {
//     fn from(value: serde_json::Error) -> Self {
//         Error::Json(value.to_string())
//     }
// }

// errors.rs
use andromeda_api::error::Error as AndromedaApiError;
use andromeda_bitcoin::error::Error as AndromedaBitcoinError;
use proton_crypto_account::proton_crypto;
use rusqlite::Error as RusqlitError;
use std::{error::Error, fmt, sync::PoisonError};

use crate::proton_wallet::{
    crypto::errors::WalletCryptoError, db::error::DatabaseError, features::error::FeaturesError,
};

#[derive(thiserror::Error, Debug)]
pub enum BridgeError {
    #[error("Error when reading PROTON_API")]
    ApiLock(String),

    /// Generic error
    #[error("An generic error occurred: {0}")]
    Generic(String),

    /// Muon auth session error
    #[error("A muon auth session error occurred: {0}")]
    MuonAuthSession(String),

    /// Muon auth refresh error
    #[error("A muon auth refresh error occurred: {0}")]
    MuonAuthRefresh(String),

    /// Muon client error
    #[error("An error occurred in muon client: {0}")]
    MuonClient(String),

    /// Muon session error
    #[error("An error occurred in muon session: {0}")]
    MuonSession(String),

    /// Andromeda bitcoin error
    #[error("An error occurred in andromeda bitcoin: {0}")]
    AndromedaBitcoin(String),

    /// Andromeda api response error
    #[error("An error occurred in andromeda api response: {0}")]
    ApiResponse(ResponseError),

    #[error("Api response deserialize error: {0}")]
    ApiDeserialize(String),

    #[error("Bitcoin response deserialize error: {0}")]
    BitcoinDeserialize(String),

    /// srp errors
    #[error("An error occurred in api srp: {0}")]
    ApiSrp(String),

    /// crypto errors
    #[error("An error occurred in aes gcm crypto: {0}")]
    AesGcm(String),

    /// wallet crypto errors
    #[error("An error occurred in wallet crypto: {0}")]
    WalletCrypto(String),

    /// wallet decryption errors
    #[error("An error occurred in wallet crypto: {0}")]
    WalletDecryption(String),

    /// wallet feature errors
    #[error("An error occurred in wallet feature: {0}")]
    WalletFeature(String),

    /// Login error
    #[error("An Login error occurred: {0}")]
    Login(String),

    /// Fork error
    #[error("An Fork error occurred: {0}")]
    Fork(String),

    #[error("Wallet database error: {0}")]
    Database(String),

    #[error("SessionStore error: {0}")]
    SessionStore(String),

    #[error("String encoding error: {0}")]
    Encoding(String),

    /// Paper wallet error
    #[error("Paper wallet had been used error: {0}")]
    InsufficientFundsInPaperWallet(String),

    #[error("Invalid paper wallet error: {0}")]
    InvalidPaperWallet(String),
}

impl From<DatabaseError> for BridgeError {
    fn from(value: DatabaseError) -> Self {
        BridgeError::Database(format!("DatabaseError occurred: {:?}", value.source()))
    }
}

impl From<WalletCryptoError> for BridgeError {
    fn from(value: WalletCryptoError) -> Self {
        if let WalletCryptoError::CryptoError(inner) = &value {
            let error_msg = inner.to_string();

            if error_msg.contains(
                "failed to initialize decryptor: gopenpgp: no decryption key material provided",
            ) {
                return BridgeError::WalletDecryption(format!(
                    "WalletCryptoError occurred: {:?}",
                    inner.to_string(),
                ));
            }
        }
        BridgeError::WalletCrypto(format!("WalletCryptoError occurred: {:?}", value.source()))
    }
}

impl From<FeaturesError> for BridgeError {
    fn from(value: FeaturesError) -> Self {
        BridgeError::WalletFeature(format!("WalletFeatureError occurred: {:?}", value.source()))
    }
}

impl From<RusqlitError> for BridgeError {
    fn from(value: RusqlitError) -> Self {
        BridgeError::Database(format!("Rusqlite Error occurred: {:?}", value.source()))
    }
}

/// rclock mutex lock error
impl<T> From<PoisonError<T>> for BridgeError {
    fn from(_: PoisonError<T>) -> Self {
        BridgeError::ApiLock(
            "Proton api service read lock error, please try to restart app".to_string(),
        )
    }
}

// impl From<String> for BridgeError {
//     fn from(value: String) -> Self {
//         BridgeError::Encoding(value)
//     }
// }

impl From<serde_json::Error> for BridgeError {
    fn from(value: serde_json::Error) -> Self {
        BridgeError::Encoding(format!("serde_json::Error occurred: {:?}", value.source()))
    }
}

impl From<andromeda_api::StoreFailure> for BridgeError {
    fn from(value: andromeda_api::StoreFailure) -> Self {
        BridgeError::SessionStore(format!(
            "andromeda_api::StoreFailure occurred: {:?}",
            value.source()
        ))
    }
}

impl From<std::str::Utf8Error> for BridgeError {
    fn from(value: std::str::Utf8Error) -> Self {
        BridgeError::Encoding(format!("Utf8Error occurred: {:?}", value.source()))
    }
}

impl From<proton_srp::MailboxHashError> for BridgeError {
    fn from(value: proton_srp::MailboxHashError) -> Self {
        BridgeError::ApiSrp(format!("MailboxHashError occurred: {:?}", value.source()))
    }
}

impl From<proton_srp::SRPError> for BridgeError {
    fn from(value: proton_srp::SRPError) -> Self {
        BridgeError::ApiSrp(format!("SRPError occurred: {:?}", value.source()))
    }
}

impl From<proton_crypto::CryptoError> for BridgeError {
    fn from(value: proton_crypto::CryptoError) -> Self {
        BridgeError::WalletCrypto(format!(
            "Proton crypto error occurred: {:?}",
            value.source()
        ))
    }
}

impl From<AndromedaBitcoinError> for BridgeError {
    fn from(error: AndromedaBitcoinError) -> Self {
        if let Some(inner_error) = find_error_type::<AndromedaApiError>(&error) {
            if let AndromedaApiError::ErrorCode(_, error) = inner_error {
                return BridgeError::ApiResponse(error.into());
            }
            if let AndromedaApiError::AuthSession(kind) = inner_error {
                return BridgeError::MuonAuthSession(format!(
                    "AuthSession: A muon {kind} error was caused by a non-existent auth session"
                ));
            }
            if let AndromedaApiError::AuthRefresh(kind) = inner_error {
                return BridgeError::MuonAuthSession(format!(
                    "AuthSession: A muon {kind} error was caused by a non-existent auth session"
                ));
            }
            if let AndromedaApiError::MuonError(me) = inner_error {
                return BridgeError::MuonClient(format!(
                    "MuonError: {me} (caused by: {source:?})",
                    source = me.source(),
                ));
            }
            if let AndromedaApiError::ErrorCode(_, error) = inner_error {
                return BridgeError::ApiResponse(error.into());
            }
        }

        if let Some(inner_error) = find_error_type::<AndromedaBitcoinError>(&error) {
            if let AndromedaBitcoinError::InsufficientFundsInPaperWallet = inner_error {
                return BridgeError::InsufficientFundsInPaperWallet(format!(
                    "PaperWallet: this paper wallet had been used"
                ));
            }

            if let AndromedaBitcoinError::InvalidPaperWallet = inner_error {
                return BridgeError::InvalidPaperWallet(format!(
                    "PaperWallet: invalid paper wallet format"
                ));
            }
        }

        match error {
            AndromedaBitcoinError::InsufficientFundsInPaperWallet => {
                return BridgeError::InsufficientFundsInPaperWallet(format!(
                    "PaperWallet: this paper wallet had been used"
                ))
            }
            AndromedaBitcoinError::InvalidPaperWallet => {
                return BridgeError::InvalidPaperWallet(format!(
                    "PaperWallet: invalid paper wallet format"
                ));
            }
            _ => {}
        }

        BridgeError::AndromedaBitcoin(format!(
            "AndromedaBitcoinError occurred: {:?}",
            error.source()
        ))
    }
}

impl From<AndromedaApiError> for BridgeError {
    fn from(error: AndromedaApiError) -> Self {
        match error {
            AndromedaApiError::AuthSession(kind) => BridgeError::MuonAuthSession(format!(
                "AuthSession: A muon {kind} error was caused by a non-existent auth session"
            )),
            AndromedaApiError::AuthRefresh(kind) => BridgeError::MuonAuthRefresh(format!(
                "AuthRefresh: A muon {kind} error was caused by a failed auth refresh"
            )),
            AndromedaApiError::MuonError(me) => BridgeError::MuonClient(format!(
                "MuonError: {me} (caused by: {source:?})",
                source = me.source(),
            )),
            AndromedaApiError::BitcoinDeserialize(bde) => BridgeError::BitcoinDeserialize(format!(
                "BitcoinDeserializeError occurred: {:?}",
                bde.source()
            )),
            AndromedaApiError::HexToArrayDecoding(hde) => BridgeError::Encoding(format!(
                "HexToArrayDecoding error occurred: {:?}",
                hde.source()
            )),
            AndromedaApiError::HexToBytesErrorDecoding(hde) => BridgeError::Encoding(format!(
                "HexToBytesErrorDecoding error occurred: {:?}",
                hde.source()
            )),
            AndromedaApiError::Http => BridgeError::Generic("HTTP error occurred".to_string()),
            AndromedaApiError::ErrorCode(_, error) => BridgeError::ApiResponse(error.into()),
            AndromedaApiError::Deserialize(err) => BridgeError::ApiDeserialize(err),
            AndromedaApiError::MuonAppVersion(err) => BridgeError::MuonSession(format!(
                "Muon MuonAppVersion occurred: {:?}",
                err.source()
            )),
            AndromedaApiError::MuonStatus(err) => BridgeError::MuonSession(format!(
                "Muon MuonStatusError occurred: {:?}",
                err.source()
            )),
            AndromedaApiError::Utf8Error(err) => {
                BridgeError::Encoding(format!("Utf8Error error occurred: {:?}", err.source()))
            }
            AndromedaApiError::ForkAuthSession => {
                BridgeError::Fork("ForkAuthSession error occurred".to_string())
            }
            AndromedaApiError::ForkSession => {
                BridgeError::Fork("ForkSession error occurred".to_string())
            }
            AndromedaApiError::LoginError => {
                BridgeError::Login("LoginError error occurred".to_string())
            }
            AndromedaApiError::UnsupportedTwoFactor => {
                BridgeError::Login("UnsupportedTwoFactor error occurred".to_string())
            }
        }
    }
}

#[derive(Debug)]
pub struct ResponseError {
    pub code: u16,
    pub error: String,
    pub details: String,
}
impl fmt::Display for ResponseError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "ResponseError:\n  Code: {}\n  Error: {}\n  Details: {}",
            self.code, self.error, self.details
        )
    }
}

impl From<andromeda_api::error::ResponseError> for ResponseError {
    fn from(value: andromeda_api::error::ResponseError) -> Self {
        ResponseError {
            code: value.Code,
            error: value.Error,
            details: value.Details.to_string(),
        }
    }
}

impl From<&andromeda_api::error::ResponseError> for ResponseError {
    fn from(value: &andromeda_api::error::ResponseError) -> Self {
        ResponseError {
            code: value.Code,
            error: value.Error.clone(),
            details: value.Details.to_string(),
        }
    }
}

fn find_error_type<T: 'static + Error>(error: &dyn Error) -> Option<&T> {
    let mut current_error = error;
    while let Some(source) = current_error.source() {
        if let Some(specific_error) = source.downcast_ref::<T>() {
            return Some(specific_error);
        }
        current_error = source;
    }
    None
}

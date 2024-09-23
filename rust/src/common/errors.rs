use std::{error::Error, fmt, sync::PoisonError};

// errors.rs
use andromeda_api::error::Error as AndromedaApiError;
use andromeda_bitcoin::error::Error as AndromedaBitcoinError;
use proton_crypto_account::proton_crypto;

use crate::proton_wallet::crypto::errors::WalletCryptoError;

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

    /// srp errors
    #[error("An error occurred in api srp: {0}")]
    ApiSrp(String),

    /// crypto errors
    #[error("An error occurred in aes gcm crypto: {0}")]
    AesGcm(String),

    /// wallet crypto errors
    #[error("An error occurred in wallet crypto: {0}")]
    WalletCrypto(String),
}

impl From<WalletCryptoError> for BridgeError {
    fn from(value: WalletCryptoError) -> Self {
        BridgeError::WalletCrypto(format!("WalletCryptoError occurred: {:?}", value.source()))
    }
}

/// rclock mutex lock error
impl<T> From<PoisonError<T>> for BridgeError {
    fn from(_: PoisonError<T>) -> Self {
        BridgeError::ApiLock("Proton api service read error, please try to restart app".to_string())
    }
}

impl From<String> for BridgeError {
    fn from(value: String) -> Self {
        BridgeError::Generic(value)
    }
}

impl From<serde_json::Error> for BridgeError {
    fn from(value: serde_json::Error) -> Self {
        BridgeError::Generic(format!("serde_json::Error occurred: {:?}", value.source()))
    }
}

impl From<andromeda_api::StoreWriteErr> for BridgeError {
    fn from(value: andromeda_api::StoreWriteErr) -> Self {
        BridgeError::Generic(format!(
            "andromeda_api::StoreWriteErr occurred: {:?}",
            value.source()
        ))
    }
}

impl From<std::str::Utf8Error> for BridgeError {
    fn from(value: std::str::Utf8Error) -> Self {
        BridgeError::Generic(format!("Utf8Error occurred: {:?}", value.source()))
    }
}

impl From<proton_srp::MailboxHashError> for BridgeError {
    fn from(value: proton_srp::MailboxHashError) -> Self {
        BridgeError::Generic(format!("MailboxHashError occurred: {:?}", value.source()))
    }
}

impl From<proton_srp::SRPError> for BridgeError {
    fn from(value: proton_srp::SRPError) -> Self {
        BridgeError::Generic(format!("SRPError occurred: {:?}", value.source()))
    }
}

impl From<proton_crypto::CryptoError> for BridgeError {
    fn from(value: proton_crypto::CryptoError) -> Self {
        BridgeError::Generic(format!(
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
            AndromedaApiError::BitcoinDeserialize(bde) => BridgeError::Generic(format!(
                "BitcoinDeserializeError occurred: {:?}",
                bde.source()
            )),
            AndromedaApiError::HexToArrayDecoding(hde) => BridgeError::Generic(format!(
                "HexToArrayDecoding error occurred: {:?}",
                hde.source()
            )),
            AndromedaApiError::HexToBytesErrorDecoding(hde) => BridgeError::Generic(format!(
                "HexToBytesErrorDecoding error occurred: {:?}",
                hde.source()
            )),
            AndromedaApiError::Http => BridgeError::Generic("HTTP error occurred".to_string()),
            AndromedaApiError::ErrorCode(_, error) => BridgeError::ApiResponse(error.into()),
            AndromedaApiError::Deserialize(err) => BridgeError::Generic(err),
            AndromedaApiError::MuonAppVersion(err) => BridgeError::MuonSession(format!(
                "Muon MuonAppVersion occurred: {:?}",
                err.source()
            )),
            AndromedaApiError::MuonStatus(err) => BridgeError::MuonSession(format!(
                "Muon MuonStatusError occurred: {:?}",
                err.source()
            )),
            AndromedaApiError::Utf8Error(err) => {
                BridgeError::Generic(format!("Utf8Error error occurred: {:?}", err.source()))
            }
        }
    }
}

// #[derive(Debug)]
// pub struct MuonStatusError {
//     pub http_code: u16,
//     pub error: String,
//     pub details: String,
// }

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

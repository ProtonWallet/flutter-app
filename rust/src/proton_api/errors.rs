use std::str::Utf8Error;

use andromeda_api::{error::Error, StoreWriteErr};
use proton_srp::MailboxHashError;

#[derive(Debug)]
pub enum ApiError {
    /// Generic error
    Generic(String),

    /// Muon session error
    #[allow(clippy::enum_variant_names)]
    SessionError(String),
}

impl From<String> for ApiError {
    fn from(value: String) -> Self {
        ApiError::Generic(value)
    }
}

impl From<StoreWriteErr> for ApiError {
    fn from(value: StoreWriteErr) -> Self {
        ApiError::Generic(value.to_string())
    }
}

impl From<Utf8Error> for ApiError {
    fn from(value: Utf8Error) -> Self {
        ApiError::Generic(value.to_string())
    }
}

impl From<MailboxHashError> for ApiError {
    fn from(value: MailboxHashError) -> Self {
        ApiError::Generic(value.to_string())
    }
}

impl From<Error> for ApiError {
    fn from(error: Error) -> Self {
        match error {
            Error::MuonError(me) => ApiError::Generic(format!("Muon error occurred: {}", me)),
            Error::BitcoinDeserializeError(bde) => {
                ApiError::Generic(format!("BitcoinDeserializeError occurred: {}", bde))
            }
            Error::HexDecoding(hde) => {
                ApiError::Generic(format!("HexDecoding error occurred: {}", hde))
            }
            Error::HttpError => ApiError::Generic("HTTP error occurred".to_string()),
            Error::ErrorCode(error) => ApiError::Generic(format!(
                "Response Code:{}\nError: {}\nDetails:{}",
                error.Code, error.Error, error.Details
            )),
            Error::DeserializeErr(err) => ApiError::Generic(err),
            Error::MuonApiVersion(err) => {
                ApiError::SessionError(format!("Muon MuonApiVersion occurred: {}", err))
            }
            Error::MuonStatueError(err) => {
                ApiError::SessionError(format!("Muon MuonStatueError occurred: {}", err))
            }
        }
    }
}

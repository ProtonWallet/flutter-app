use std::error::Error;

// errors.rs
use andromeda_api::error::Error as AndromedaApiError;
use andromeda_bitcoin::error::Error as AndromedaBitcoinError;

#[derive(thiserror::Error, Debug)]
pub enum BridgeError {
    #[error("An error occurred in andromeda api: {0}")]
    AndromedaApi(String),

    /// Generic error
    #[error("An generic error occurred: {0}")]
    Generic(String),

    /// Muon session error
    #[error("An error occurred in muon session: {0}")]
    MuonSession(String),

    /// Andromeda bitcoin error
    #[error("An error occurred in andromeda bitcoin: {0}")]
    AndromedaBitcoin(String),

    /// Andromeda api response error
    #[error("An error occurred in andromeda bitcoin: {0}")]
    ApiResponse(String),
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

impl From<AndromedaBitcoinError> for BridgeError {
    fn from(value: AndromedaBitcoinError) -> Self {
        BridgeError::AndromedaBitcoin(format!(
            "AndromedaBitcoinError occurred: {:?}",
            value.source()
        ))
    }
}

impl From<AndromedaApiError> for BridgeError {
    fn from(error: AndromedaApiError) -> Self {
        match error {
            AndromedaApiError::MuonError(me) => {
                BridgeError::Generic(format!("Muon error occurred: {:?}", me.source()))
            }
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
            AndromedaApiError::ErrorCode(error) => BridgeError::ApiResponse(format!(
                "Response Code:{}\nError: {}\nDetails:{}",
                error.Code, error.Error, error.Details
            )),
            AndromedaApiError::Deserialize(err) => BridgeError::Generic(err),
            AndromedaApiError::MuonApiVersion(err) => BridgeError::MuonSession(format!(
                "Muon MuonApiVersion occurred: {:?}",
                err.source()
            )),
            AndromedaApiError::MuonStatus(err) => BridgeError::MuonSession(format!(
                "Muon MuonStatueError occurred: {:?}",
                err.source()
            )),
        }
    }
}

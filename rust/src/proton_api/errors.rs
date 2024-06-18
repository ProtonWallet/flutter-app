use andromeda_api::error::Error as AndromedaApiError;

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
}

impl From<String> for BridgeError {
    fn from(value: String) -> Self {
        BridgeError::Generic(value)
    }
}

impl From<andromeda_api::StoreWriteErr> for BridgeError {
    fn from(value: andromeda_api::StoreWriteErr) -> Self {
        BridgeError::Generic(value.to_string())
    }
}

impl From<std::str::Utf8Error> for BridgeError {
    fn from(value: std::str::Utf8Error) -> Self {
        BridgeError::Generic(value.to_string())
    }
}

impl From<proton_srp::MailboxHashError> for BridgeError {
    fn from(value: proton_srp::MailboxHashError) -> Self {
        BridgeError::Generic(value.to_string())
    }
}

impl From<AndromedaApiError> for BridgeError {
    fn from(error: AndromedaApiError) -> Self {
        match error {
            AndromedaApiError::MuonError(me) => {
                BridgeError::Generic(format!("Muon error occurred: {}", me))
            }
            AndromedaApiError::BitcoinDeserializeError(bde) => {
                BridgeError::Generic(format!("BitcoinDeserializeError occurred: {}", bde))
            }
            AndromedaApiError::HexDecoding(hde) => {
                BridgeError::Generic(format!("HexDecoding error occurred: {}", hde))
            }
            AndromedaApiError::HttpError => BridgeError::Generic("HTTP error occurred".to_string()),
            AndromedaApiError::ErrorCode(error) => BridgeError::Generic(format!(
                "Response Code:{}\nError: {}\nDetails:{}",
                error.Code, error.Error, error.Details
            )),
            AndromedaApiError::DeserializeErr(err) => BridgeError::Generic(err),
            AndromedaApiError::MuonApiVersion(err) => {
                BridgeError::MuonSession(format!("Muon MuonApiVersion occurred: {}", err))
            }
            AndromedaApiError::MuonStatueError(err) => {
                BridgeError::MuonSession(format!("Muon MuonStatueError occurred: {}", err))
            }
        }
    }
}

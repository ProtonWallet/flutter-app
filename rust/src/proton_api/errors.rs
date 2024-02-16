use andromeda_api::error::Error;
use muon::session::Error as SessionError;


#[derive(Debug)]
pub enum ApiError {
    /// Generic error
    Generic(String),

    /// Muon session error
    #[allow(clippy::enum_variant_names)]
    SessionError(String),
}


impl From<SessionError> for ApiError {
    fn from(value: SessionError) -> Self {
        ApiError::SessionError(value.to_string())
    }
}

impl From<String> for ApiError {
    fn from(value: String) -> Self {
        ApiError::Generic(value)
    }
}

impl From<Error> for ApiError {
    fn from(error: Error) -> Self {
        match error {
            Error::MuonError(me) => ApiError::Generic(format!("Muon error occurred: {}", me)),
            Error::MuonSessionError(mse) => ApiError::SessionError(format!("Muon session error: {}", mse)),
            Error::DeserializeError => ApiError::Generic("Deserialization error occurred".to_string()),
            Error::SerializeError => ApiError::Generic("Serialization error occurred".to_string()),
            Error::HttpError => ApiError::Generic("HTTP error occurred".to_string()),
            // Error::GeneralError(strErr) => ApiError::Generic(format!("Generic error occurred: {}",strErr)),
        }
    }
}
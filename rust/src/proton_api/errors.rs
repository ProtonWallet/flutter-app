use andromeda_api::error::Error;

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

impl From<Error> for ApiError {
    fn from(error: Error) -> Self {
        match error {
            Error::MuonError(me) => ApiError::Generic(format!("Muon error occurred: {}", me)),
            Error::MuonSessionError => ApiError::SessionError("Muon session error".to_string()),
            Error::MuonRequestError(mre) => {
                ApiError::SessionError(format!("Muon request error: {}", mre))
            }
            Error::DeserializeError => {
                ApiError::Generic("Deserialization error occurred".to_string())
            }
            Error::SerializeError => ApiError::Generic("Serialization error occurred".to_string()),
            Error::HttpError => ApiError::Generic("HTTP error occurred".to_string()),
        }
    }
}

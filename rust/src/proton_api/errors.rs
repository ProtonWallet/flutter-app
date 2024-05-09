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
            Error::MuonSessionError(mse) => {
                ApiError::SessionError(format!("Muon session error occurred: {}", mse))
            }
            Error::MuonRequestError(mre) => {
                ApiError::SessionError(format!("Muon request error: {}", mre))
            }
            Error::BitcoinDeserializeError(bde) => {
                ApiError::Generic(format!("BitcoinDeserializeError occurred: {}", bde))
            }
            Error::HexDecoding(hde) => {
                ApiError::Generic(format!("HexDecoding error occurred: {}", hde))
            }
            Error::HttpError => ApiError::Generic("HTTP error occurred".to_string()),
            Error::ErrorCode(error) => ApiError::Generic(format!(
                "Response Code:{} Details:{}",
                error.code, error.details
            )),
            Error::DeserializeErr(err) => ApiError::Generic(err),
        }
    }
}

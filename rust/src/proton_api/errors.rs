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

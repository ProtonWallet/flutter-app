use aes_gcm::Error as AesGcmError;

#[derive(Debug, thiserror::Error)]
pub enum WalletCryptoError {
    #[error("Aes gcm crypto error: {0}")]
    AesGcm(String),

    #[error("base64 decode error: {0}")]
    Decode(#[from] base64::DecodeError),

    #[error("utf8 error: {0}")]
    Utf8(#[from] std::str::Utf8Error),

    #[error("Invalid aes gcm key length error")]
    AesGcmInvalidKeyLength,

    #[error("Invalid encrypted data length error")]
    InvalidDataSize,
}

// map aes_gcm::Error to WalletCryptoError
impl From<AesGcmError> for WalletCryptoError {
    fn from(err: AesGcmError) -> Self {
        WalletCryptoError::AesGcm(format!("{:?}", err))
    }
}

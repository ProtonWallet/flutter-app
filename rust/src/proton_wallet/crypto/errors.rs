use aes_gcm::Error as AesGcmError;
use proton_crypto::crypto::VerificationError;
use proton_crypto_account::proton_crypto::CryptoError;

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

    #[error("Proton crypto error: {0}")]
    CryptoError(#[from] CryptoError),

    #[error("Crypto steam writer error: {0}")]
    CryptoWriteError(#[from] std::io::Error),

    #[error("Crypto signature verification error: {0}")]
    CryptoSignatureVerify(#[from] VerificationError),

    #[error("No user keys or address keys found error")]
    NoKeysFound,
}

// map aes_gcm::Error to WalletCryptoError
impl From<AesGcmError> for WalletCryptoError {
    fn from(err: AesGcmError) -> Self {
        WalletCryptoError::AesGcm(format!("{:?}", err.to_string()))
    }
}

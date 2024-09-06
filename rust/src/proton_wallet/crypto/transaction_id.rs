use core::str;

use super::{errors::WalletCryptoError, user_key::UserKey};

use base64::{prelude::BASE64_STANDARD, Engine};
/// place holder
pub struct WalletTransactionID(Vec<u8>);
impl WalletTransactionID {
    pub fn new(data: Vec<u8>) -> Self {
        Self(data)
    }

    pub fn new_from_str(plaintext: &str) -> Self {
        Self::new(plaintext.as_bytes().to_vec())
    }

    pub fn new_from_base64(base64: &str) -> Result<Self, WalletCryptoError> {
        Ok(BASE64_STANDARD.decode(base64).map(Self::new)?)
    }

    pub fn to_base64(&self) -> String {
        BASE64_STANDARD.encode(&self.0)
    }

    pub fn as_utf8_string(&self) -> Result<String, WalletCryptoError> {
        Ok(str::from_utf8(&self.0)?.to_string())
    }
}

/// encryption
impl WalletTransactionID {
    pub fn encrypt_with(
        &self,
        key: &UserKey,
    ) -> Result<EncryptedWalletTransactionID, WalletCryptoError> {
        let _ = key;
        Ok(EncryptedWalletTransactionID(Vec::new()))
    }
}

pub struct EncryptedWalletTransactionID(Vec<u8>);
impl EncryptedWalletTransactionID {
    pub fn new(data: Vec<u8>) -> Self {
        Self(data)
    }

    pub fn new_from_base64(base64: &str) -> Result<Self, WalletCryptoError> {
        Ok(BASE64_STANDARD.decode(base64).map(Self::new)?)
    }

    pub fn to_base64(&self) -> String {
        BASE64_STANDARD.encode(&self.0)
    }
}

/// decryption
impl EncryptedWalletTransactionID {
    pub fn decrypt_with(&self, _key: &UserKey) -> Result<WalletTransactionID, WalletCryptoError> {
        todo!("Implement decryption")
    }
}

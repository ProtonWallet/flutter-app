use core::str;

use super::{errors::WalletCryptoError, wallet_key::UnlockedWalletKey};

use base64::{prelude::BASE64_STANDARD, Engine};
use secrecy::{ExposeSecret, SecretString, SecretVec};

/// `WalletMnemonic` holds a secret mnemonic phrase that is used for generating wallet keys.
/// The mnemonic is stored securely in a `SecretVec` to protect it from accidental exposure in memory.
pub struct WalletMnemonic {
    pub mnemonic: SecretVec<u8>,
}
impl WalletMnemonic {
    pub fn new(data: Vec<u8>) -> Self {
        Self {
            mnemonic: SecretVec::new(data),
        }
    }

    pub fn new_from_str(plaintext: &str) -> Self {
        Self::new(plaintext.as_bytes().to_vec())
    }

    pub fn new_from_base64(base64: &str) -> Result<Self, WalletCryptoError> {
        Ok(BASE64_STANDARD.decode(base64).map(Self::new)?)
    }

    pub fn to_base64(&self) -> SecretString {
        SecretString::new(BASE64_STANDARD.encode(self.mnemonic.expose_secret()))
    }

    pub fn as_utf8_string(&self) -> Result<SecretString, WalletCryptoError> {
        let plaintext = str::from_utf8(self.mnemonic.expose_secret())?.to_string();
        Ok(SecretString::new(plaintext))
    }
}

/// encryption
impl WalletMnemonic {
    /// Encrypts the mnemonic using the provided `UnlockedWalletKey`.
    ///
    /// The mnemonic is encrypted using AES-GCM, ensuring that it is securely protected.
    ///
    /// # Parameters
    /// - `key`: A reference to an `UnlockedWalletKey` that will be used to encrypt the mnemonic.
    ///
    /// # Returns
    /// - `Ok(EncryptedWalletMnemonic)`: On success, returns an `EncryptedWalletMnemonic` containing the encrypted mnemonic.
    /// - `Err(WalletCryptoError)`: On failure, returns an error describing what went wrong during encryption
    pub fn encrypt_with(
        &self,
        key: &UnlockedWalletKey,
    ) -> Result<EncryptedWalletMnemonic, WalletCryptoError> {
        key.encrypt(self.mnemonic.expose_secret())
            .map(EncryptedWalletMnemonic::new)
    }
}

pub struct EncryptedWalletMnemonic(Vec<u8>);
impl EncryptedWalletMnemonic {
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
impl EncryptedWalletMnemonic {
    /// Decrypts the encrypted mnemonic using the provided `UnlockedWalletKey`.
    ///
    /// This method decrypts the mnemonic, returning it as a `WalletMnemonic` wrapped in a `SecretVec` for security.
    ///
    /// # Parameters
    /// - `key`: A reference to an `UnlockedWalletKey` that will be used to decrypt the mnemonic.
    ///
    /// # Returns
    /// - `Ok(WalletMnemonic)`: On success, returns the decrypted `WalletMnemonic`.
    /// - `Err(WalletCryptoError)`: On failure, returns an error describing what went wrong during decryption.
    pub fn decrypt_with(
        &self,
        key: &UnlockedWalletKey,
    ) -> Result<WalletMnemonic, WalletCryptoError> {
        key.decrypt(&self.0).map(WalletMnemonic::new)
    }
}
use base64::{prelude::BASE64_STANDARD, Engine};
use core::str;
use secrecy::{ExposeSecret, SecretString, SecretVec};
use zeroize::{Zeroize, ZeroizeOnDrop};

use super::{wallet_key::UnlockedWalletKey, Result};

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

    pub fn new_from_base64(base64: &str) -> Result<Self> {
        Ok(BASE64_STANDARD.decode(base64).map(Self::new)?)
    }

    pub fn to_base64(&self) -> SecretString {
        SecretString::new(BASE64_STANDARD.encode(self.mnemonic.expose_secret()))
    }

    pub fn as_utf8_string(&self) -> Result<SecretString> {
        let plaintext = str::from_utf8(self.mnemonic.expose_secret())?.to_string();
        Ok(SecretString::new(plaintext))
    }
}

impl From<String> for WalletMnemonic {
    fn from(value: String) -> Self {
        Self::new(value.into())
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
    pub fn encrypt_with(&self, key: &UnlockedWalletKey) -> Result<EncryptedWalletMnemonic> {
        key.encrypt(self.mnemonic.expose_secret())
            .map(EncryptedWalletMnemonic::new)
    }
}

#[derive(Clone, PartialEq, Eq, Zeroize, ZeroizeOnDrop)]
pub struct EncryptedWalletMnemonic(Vec<u8>);
impl EncryptedWalletMnemonic {
    pub fn new(data: Vec<u8>) -> Self {
        Self(data)
    }

    pub fn new_from_base64(base64: &str) -> Result<Self> {
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
    pub fn decrypt_with(&self, key: &UnlockedWalletKey) -> Result<WalletMnemonic> {
        key.decrypt(&self.0).map(WalletMnemonic::new)
    }
}

#[cfg(test)]
mod tests {
    use secrecy::ExposeSecret;

    use crate::proton_wallet::crypto::mnemonic::{EncryptedWalletMnemonic, WalletMnemonic};

    #[test]
    fn test_new_wallet_mnemonic_from_str() {
        let plaintext = "test mnemonic phrase";
        let mnemonic = WalletMnemonic::new_from_str(plaintext);
        assert_eq!(
            mnemonic.as_utf8_string().unwrap().expose_secret(),
            plaintext
        );
    }

    #[test]
    fn test_new_wallet_mnemonic_from_base64() {
        let base64_data = "dGVzdCBtbmVtb25pYyBwaHJhc2U="; // base64 for "test mnemonic phrase"
        let mnemonic = WalletMnemonic::new_from_base64(base64_data).unwrap();
        assert_eq!(mnemonic.mnemonic.expose_secret(), b"test mnemonic phrase");
        assert_eq!(mnemonic.to_base64().expose_secret(), base64_data);
    }

    #[test]
    fn test_wallet_mnemonic_to_base64() {
        let mnemonic = WalletMnemonic::new_from_str("test mnemonic phrase");
        let base64_encoded = mnemonic.to_base64();

        assert_eq!(
            base64_encoded.expose_secret(),
            "dGVzdCBtbmVtb25pYyBwaHJhc2U="
        );
    }

    #[test]
    fn test_wallet_mnemonic_as_utf8_string() {
        let mnemonic = WalletMnemonic::from("test mnemonic phrase".to_string());
        let utf8_string = mnemonic.as_utf8_string().unwrap();
        assert_eq!(utf8_string.expose_secret(), "test mnemonic phrase");
    }

    #[test]
    fn test_new_enc_wallet_mnemonic_from_base64() {
        let base64_data = "dGVzdCBtbmVtb25pYyBwaHJhc2U="; // base64 for "test mnemonic phrase"
        let mnemonic = EncryptedWalletMnemonic::new_from_base64(base64_data).unwrap();
        assert_eq!(mnemonic.to_base64(), base64_data);
    }
}

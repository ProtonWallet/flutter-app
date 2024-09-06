use core::str;

use super::{errors::WalletCryptoError, wallet_key::UnlockedWalletKey};

use base64::{prelude::BASE64_STANDARD, Engine};

pub trait Label {
    fn new(data: Vec<u8>) -> Self;
    fn as_bytes(&self) -> &[u8];

    /// Pre-implemented
    /// Creates a label from a plaintext string.
    fn new_from_str(plaintext: &str) -> Self
    where
        Self: Sized,
    {
        Self::new(plaintext.as_bytes().to_vec())
    }

    /// Pre-implemented
    /// Creates a label from a base64-encoded string
    fn new_from_base64(base64: &str) -> Result<Self, WalletCryptoError>
    where
        Self: Sized,
    {
        let decoded_data = BASE64_STANDARD.decode(base64)?;
        Ok(Self::new(decoded_data))
    }

    /// Pre-implemented
    /// Converts the label into a base64-encoded string.
    fn to_base64(&self) -> String
    where
        Self: Sized,
    {
        BASE64_STANDARD.encode(self.as_bytes())
    }

    /// Pre-implemented
    /// Converts the label's byte data to a UTF-8 string.
    fn as_utf8_string(&self) -> Result<String, WalletCryptoError>
    where
        Self: Sized,
    {
        Ok(str::from_utf8(self.as_bytes())?.to_string())
    }

    /// Pre-implemented
    /// Encrypts the label using the provided `UnlockedWalletKey`.
    ///
    /// The label is encrypted using AES-GCM encryption algorithm
    ///
    /// # Parameters
    /// - `key`: A reference to an `UnlockedWalletKey` that will be used to encrypt the label.
    ///
    /// # Returns
    /// - `Ok(EncryptedLabel<Self>)`: On success, returns an encrypted version of the label.
    /// - `Err(WalletCryptoError)`: On failure, returns an error describing what went wrong during encryption.
    fn encrypt_with(
        &self,
        key: &UnlockedWalletKey,
    ) -> Result<EncryptedLabel<Self>, WalletCryptoError>
    where
        Self: Sized,
    {
        key.encrypt(self.as_bytes()).map(EncryptedLabel::new)
    }
}

/// Type safe EncryptedLabel
/// The label can be of any type that implements the `Label` trait, such as WalletName, WalletAccountLabel, or TransactionLabel.
pub struct EncryptedLabel<T>(Vec<u8>, std::marker::PhantomData<T>);
impl<T> EncryptedLabel<T>
where
    T: Label,
{
    /// Creates a new `EncryptedLabel` with the provided encrypted data.
    pub fn new(data: Vec<u8>) -> Self {
        Self(data, std::marker::PhantomData)
    }

    /// Create an `EncryptedLabel` from a base64-encoded str.
    pub fn new_from_base64(base64: &str) -> Result<Self, WalletCryptoError> {
        Ok(BASE64_STANDARD.decode(base64).map(Self::new)?)
    }

    /// Converts the encrypted label to a base64-encoded string.
    pub fn to_base64(&self) -> String {
        BASE64_STANDARD.encode(&self.0)
    }

    pub fn as_bytes(&self) -> &[u8] {
        &self.0
    }

    /// Decrypts the encrypted label using the provided `UnlockedWalletKey`.
    ///
    /// The decrypted data is returned as an instance of the generic type `T` (e.g., `WalletName`, `WalletAccountLabel`, `TransactionLabel`).
    ///
    /// # Parameters
    /// - `key`: A reference to an `UnlockedWalletKey` that will be used to decrypt the label.
    ///
    /// # Returns
    /// - `Ok(T)`: On success, returns the decrypted label of type `T`.
    /// - `Err(WalletCryptoError)`: On failure, returns an error describing what went wrong during decryption.
    pub fn decrypt_with(&self, key: &UnlockedWalletKey) -> Result<T, WalletCryptoError> {
        key.decrypt(&self.0).map(T::new)
    }
}

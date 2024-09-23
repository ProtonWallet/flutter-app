use super::{
    binary::{Binary, EncryptedBinary},
    errors::WalletCryptoError,
    wallet_key::UnlockedWalletKey,
};

pub trait Label: Binary {
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
impl<T> EncryptedBinary for EncryptedLabel<T>
where
    T: Label,
{
    /// Creates a new `EncryptedLabel` with the provided encrypted data.
    fn new(data: Vec<u8>) -> Self {
        Self(data, std::marker::PhantomData)
    }

    fn as_bytes(&self) -> &[u8] {
        &self.0
    }
}

impl<T> EncryptedLabel<T>
where
    T: Label,
{
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

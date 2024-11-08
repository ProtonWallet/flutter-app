use super::{
    binary::{Binary, EncryptedBinary},
    public_key::PublicKeys,
    Result,
};

use proton_crypto::crypto::{
    DataEncoding, Decryptor, DecryptorSync, Encryptor, EncryptorSync, PGPProviderSync, VerifiedData,
};
use proton_crypto_account::keys::UnlockedAddressKeys;

/// A trait representing a message that can be encrypted and decrypted.
/// This trait extends `Binary` and provides default implementations for encryption using public keys.
pub trait Message: Binary {
    /// Pre-implemented
    /// Encrypts the message using the provided public keys.
    ///
    /// The message is encrypted using PGP-like encryption provided by the `provider`.
    ///
    /// # Parameters
    /// - `provider`: The cryptographic provider responsible for performing the encryption (e.g., PGP).
    /// - `pub_keys`: A collection of public keys to be used for encryption.
    ///
    /// # Returns
    /// - `Ok(EncryptedMessage<Self>)`: On success, returns an encrypted version of the message.
    /// - `Err(WalletCryptoError)`: On failure, returns an error describing what went wrong during encryption.
    fn encrypt_with<Provider: PGPProviderSync>(
        &self,
        provider: &Provider,
        pub_keys: &PublicKeys<Provider>,
    ) -> Result<EncryptedMessage<Self>>
    where
        Self: Sized,
    {
        Ok(EncryptedMessage::new(
            provider
                .new_encryptor()
                .with_encryption_keys(pub_keys.as_public_keys())
                .encrypt_raw(self.as_bytes(), DataEncoding::Armor)?,
        ))
    }
}

/// A type-safe encrypted message wrapper.
/// This can store encrypted data for any type that implements the `Message` trait(e.g. `WalletMessage``).
pub struct EncryptedMessage<T>(Vec<u8>, std::marker::PhantomData<T>);
impl<T> EncryptedBinary for EncryptedMessage<T>
where
    T: Message,
{
    /// Creates a new `EncryptedLabel` with the provided encrypted data.
    fn new(data: Vec<u8>) -> Self {
        Self(data, std::marker::PhantomData)
    }

    fn as_bytes(&self) -> &[u8] {
        &self.0
    }
}

impl<T> EncryptedMessage<T>
where
    T: Message,
{
    pub fn as_armored(&self) -> Result<String> {
        self.as_utf8_string()
    }

    /// Decrypts the encrypted message using the provided address keys.
    ///
    /// The decrypted data is returned as an instance of the type `T` (e.g., `WalletMessage`).
    ///
    /// # Parameters
    /// - `provider`: The cryptographic provider responsible for decryption (e.g., PGP).
    /// - `address_keys`: The unlocked private keys that will be used to decrypt the message.
    ///
    /// # Returns
    /// - `Ok(T)`: On success, returns the decrypted message of type `T`.
    /// - `Err(WalletCryptoError)`: On failure, returns an error describing what went wrong during decryption.
    pub fn decrypt_with<Provider: PGPProviderSync>(
        &self,
        provider: &Provider,
        address_keys: &UnlockedAddressKeys<Provider>,
    ) -> Result<T> {
        Ok(T::new(
            provider
                .new_decryptor()
                .with_decryption_key_refs(address_keys.as_ref())
                .decrypt(&self.0, DataEncoding::Armor)?
                .into_vec(),
        ))
    }
}

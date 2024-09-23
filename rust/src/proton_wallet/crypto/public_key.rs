use proton_crypto::crypto::DataEncoding;
use proton_crypto_account::{
    keys::{AddressKeys, ArmoredPrivateKey},
    proton_crypto::crypto::PGPProviderSync,
};

use super::errors::WalletCryptoError;

/// Collection of public keys.
pub struct PublicKeys<Provider: PGPProviderSync>(Vec<Provider::PublicKey>);

impl<Provider: PGPProviderSync> Default for PublicKeys<Provider> {
    fn default() -> Self {
        Self::new()
    }
}

impl<Provider: PGPProviderSync> PublicKeys<Provider> {
    /// Creates a new, empty collection of public keys.
    pub fn new() -> Self {
        Self(vec![])
    }

    pub fn as_public_keys(&self) -> &[Provider::PublicKey] {
        &self.0
    }

    /// Adds a public key from an `AddressKeys` struct to the collection.
    /// This method extracts public keys from a set of address keys and adds them to the internal vector.
    pub fn add_address_keys(
        &mut self,
        provider: &Provider,
        address_keys: &AddressKeys,
    ) -> Result<(), WalletCryptoError> {
        for key in address_keys.as_ref() {
            // Import the public key from the private key in the AddressKeys set.
            self.import_and_add_key(provider, key.private_key.as_ref())?;
        }
        Ok(())
    }

    /// placeholder for future implementation we dont need it for now no use cases
    // pub fn add_api_address_keys(
    //     &mut self,
    //     provider: &Provider,
    //     address_keys: &APIPublicAddressKeys,
    // ) -> Result<(), WalletCryptoError> {
    //     let keys = address_keys.import(&provider)?;
    //     Ok(())
    // }

    /// Adds a public key from an individual `ArmoredPrivateKey` to the collection.
    pub fn add_armored_key(
        &mut self,
        provider: &Provider,
        armored_key: &ArmoredPrivateKey,
    ) -> Result<(), WalletCryptoError> {
        self.import_and_add_key(provider, armored_key.as_ref())
    }

    /// Helper method to import a public key from a private key and add it to the collection.
    fn import_and_add_key(
        &mut self,
        provider: &Provider,
        private_key: &str,
    ) -> Result<(), WalletCryptoError> {
        // Add the public key to the internal collection
        self.0
            .push(provider.public_key_import(private_key, DataEncoding::Armor)?);
        Ok(())
    }
}

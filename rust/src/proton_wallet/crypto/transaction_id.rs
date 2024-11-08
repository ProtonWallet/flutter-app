use base64::{prelude::BASE64_STANDARD, Engine};
use core::str;
use proton_crypto_account::proton_crypto::crypto::{
    DataEncoding, Decryptor, DecryptorSync, Encryptor, EncryptorSync, PGPProviderSync, VerifiedData,
};

use super::{private_key::UnlockedPrivateKeys, Result};

/// This ID can be converted to/from strings and it is clear text
#[derive(Debug)]
pub struct WalletTransactionID(Vec<u8>);
impl WalletTransactionID {
    pub fn new(data: Vec<u8>) -> Self {
        Self(data)
    }

    pub fn new_from_str(plaintext: &str) -> Self {
        Self::new(plaintext.as_bytes().to_vec())
    }

    pub fn new_from_base64(base64: &str) -> Result<Self> {
        Ok(BASE64_STANDARD.decode(base64).map(Self::new)?)
    }

    pub fn to_base64(&self) -> String {
        BASE64_STANDARD.encode(&self.0)
    }

    pub fn as_utf8_string(&self) -> Result<String> {
        Ok(str::from_utf8(&self.0)?.to_string())
    }
}

impl Default for WalletTransactionID {
    fn default() -> Self {
        Self::new(Vec::new())
    }
}

/// encryption
impl WalletTransactionID {
    /// Encrypts the transaction ID using the provided encryption keys.
    /// Lock up your precious transaction ID in a cryptographic vault and keep it safe!
    ///
    /// Notes: UnlockedPrivateKeys could be BvE address key or primary user key
    pub fn encrypt_with<Provider: PGPProviderSync>(
        &self,
        provider: &Provider,
        unlocked_keys: &UnlockedPrivateKeys<Provider>,
    ) -> Result<EncryptedWalletTransactionID> {
        let encrypted = provider
            .new_encryptor()
            .with_encryption_key(&unlocked_keys.as_self_encryption_public_key()?)
            .encrypt_raw(&self.0, DataEncoding::Armor)?;
        Ok(EncryptedWalletTransactionID::new(encrypted))
    }
}

/// An encrypted wallet transaction ID.
#[derive(Debug)]
pub struct EncryptedWalletTransactionID(Vec<u8>);
impl EncryptedWalletTransactionID {
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

impl From<String> for EncryptedWalletTransactionID {
    fn from(value: String) -> Self {
        Self::new(value.into())
    }
}

/// decryption
impl EncryptedWalletTransactionID {
    /// Decrypts the encrypted transaction ID using the provided decryption keys.
    ///
    /// Notes: try all keys to decrypt the transaction ID
    pub fn decrypt_with<T: PGPProviderSync>(
        &self,
        provider: &T,
        unlocked_keys: &UnlockedPrivateKeys<T>,
    ) -> Result<WalletTransactionID> {
        Ok(WalletTransactionID::new(
            provider
                .new_decryptor()
                .with_decryption_key_refs(unlocked_keys.user_keys.as_ref())
                .with_decryption_key_refs(unlocked_keys.addr_keys.as_ref())
                .decrypt(&self.0, DataEncoding::Armor)?
                .into_vec(),
        ))
    }
}

#[cfg(test)]
mod tests {
    use crate::{
        mocks::user_keys::tests::{
            get_test_user_2_locked_address_key, get_test_user_2_locked_user_key_secret,
            get_test_user_2_locked_user_keys,
        },
        proton_wallet::crypto::private_key::LockedPrivateKeys,
    };

    use super::*;
    use base64::{engine::general_purpose::STANDARD as BASE64_STANDARD, Engine};
    use proton_crypto::new_pgp_provider;

    #[test]
    fn test_new_from_str() {
        let plaintext = "test transaction id";
        let tx_id = WalletTransactionID::new_from_str(plaintext);
        assert_eq!(tx_id.0, plaintext.as_bytes());
    }

    #[test]
    fn test_new_from_base64() {
        let base64_data = BASE64_STANDARD.encode(b"test transaction id");
        let tx_id = WalletTransactionID::new_from_base64(&base64_data).unwrap();
        assert_eq!(tx_id.0, b"test transaction id");
    }

    #[test]
    fn test_to_base64() {
        let tx_id = WalletTransactionID::new(b"test transaction id".to_vec());
        let base64_encoded = tx_id.to_base64();
        assert_eq!(
            base64_encoded,
            BASE64_STANDARD.encode(b"test transaction id")
        );
    }

    #[test]
    fn test_as_utf8_string() {
        let tx_id = WalletTransactionID::new(b"test transaction id".to_vec());
        let utf8_string = tx_id.as_utf8_string().unwrap();
        assert_eq!(utf8_string, "test transaction id");
    }

    #[test]
    fn test_encrypted_wallet_transaction_new() {
        let data = vec![0xff, 0xfe, 0xfd];
        let result = EncryptedWalletTransactionID::new(data);
        assert!(!result.to_base64().is_empty());
    }

    #[test]
    fn test_encrypted_wallet_transaction_base64() {
        let data = BASE64_STANDARD.encode("test encrypted transaction id");
        let label = EncryptedWalletTransactionID::new_from_base64(&data).unwrap();
        let result = label.to_base64();
        assert_eq!(result, data);
    }

    #[test]
    fn test_encrypt_and_decrypt() {
        let locked_user_keys = get_test_user_2_locked_user_keys();
        let key_secret = get_test_user_2_locked_user_key_secret();

        let locked_address_keys = get_test_user_2_locked_address_key();

        let locked_keys = LockedPrivateKeys {
            user_keys: locked_user_keys,
            addr_keys: locked_address_keys,
        };

        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_keys.unlock_with(&provider, &key_secret);
        let tx_id = WalletTransactionID::new(b"test transaction id".to_vec());

        // this will encrypt tx_id with address keys
        let encrypted_tx_id = tx_id
            .encrypt_with(&provider, &unlocked_private_keys)
            .unwrap();

        // init unlocked keys with address key only
        let unlocked_addr_keys = UnlockedPrivateKeys::from_addr_key(
            unlocked_private_keys.addr_keys.first().unwrap().clone(),
        );
        let unencrypted_tx_id = encrypted_tx_id
            .decrypt_with(&provider, &unlocked_addr_keys)
            .unwrap();

        assert_eq!(
            unencrypted_tx_id.as_utf8_string().unwrap(),
            tx_id.as_utf8_string().unwrap()
        );

        //  unlock with all keys
        let unencrypted_tx_id = encrypted_tx_id
            .decrypt_with(&provider, &unlocked_private_keys)
            .unwrap();

        assert_eq!(
            unencrypted_tx_id.as_utf8_string().unwrap(),
            tx_id.as_utf8_string().unwrap()
        );
    }

    #[test]
    fn test_encrypt_and_decrypt_fail() {
        let locked_user_keys = get_test_user_2_locked_user_keys();
        let key_secret = get_test_user_2_locked_user_key_secret();

        let locked_address_keys = get_test_user_2_locked_address_key();

        let locked_keys = LockedPrivateKeys {
            user_keys: locked_user_keys,
            addr_keys: locked_address_keys,
        };

        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_keys.unlock_with(&provider, &key_secret);
        let tx_id = WalletTransactionID::new(b"test transaction id".to_vec());

        // this will encrypt tx_id with address keys
        let encrypted_tx_id = tx_id
            .encrypt_with(&provider, &unlocked_private_keys)
            .unwrap();

        // init unlocked keys with address key only
        let unlocked_user_key = UnlockedPrivateKeys::from_user_key(
            unlocked_private_keys.user_keys.first().unwrap().clone(),
        );
        let unencrypted_tx_id = encrypted_tx_id.decrypt_with(&provider, &unlocked_user_key);
        assert!(unencrypted_tx_id.is_err());
        println!("{}", unencrypted_tx_id.unwrap_err());
    }
}

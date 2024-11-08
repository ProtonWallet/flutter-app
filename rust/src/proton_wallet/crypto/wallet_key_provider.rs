use aes_gcm::{
    aead::{KeyInit, OsRng},
    Aes256Gcm, Key,
};
use base64::{prelude::BASE64_STANDARD, Engine};

use super::{errors::WalletCryptoError, wallet_key::UnlockedWalletKey, Result};

pub trait WalletKeyInterface {
    fn generate() -> UnlockedWalletKey;
    fn restore(key_bytes: &[u8]) -> Result<UnlockedWalletKey>;
    fn restore_base64(key_base64: &str) -> Result<UnlockedWalletKey>;
}

pub(crate) struct WalletKeyProvider {}

impl WalletKeyInterface for WalletKeyProvider {
    // generate a random wallet key 256 bits
    fn generate() -> UnlockedWalletKey {
        let key: Key<Aes256Gcm> = Aes256Gcm::generate_key(OsRng);
        UnlockedWalletKey(key)
    }

    // restore a wallet key from a byte array
    fn restore(key_bytes: &[u8]) -> Result<UnlockedWalletKey> {
        if key_bytes.len() != 32 {
            return Err(WalletCryptoError::AesGcmInvalidKeyLength);
        }
        Ok(UnlockedWalletKey::new(key_bytes))
    }

    // restore wallet key from encode base64 string
    fn restore_base64(key_base64: &str) -> Result<UnlockedWalletKey> {
        let key_bytes = BASE64_STANDARD.decode(key_base64)?;
        // Check if the decoded key length is correct (32 bytes for AES-256-GCM).
        if key_bytes.len() != 32 {
            // The key is not of the correct length. Return an error
            return Err(WalletCryptoError::AesGcmInvalidKeyLength);
        }

        Ok(UnlockedWalletKey::new(&key_bytes))
    }
}

#[cfg(test)]
mod tests {
    use base64::{prelude::BASE64_STANDARD, Engine};

    use crate::proton_wallet::crypto::wallet_key_provider::{
        WalletKeyInterface, WalletKeyProvider,
    };

    #[test]
    fn test_generate() {
        let unlocked_key = WalletKeyProvider::generate();
        assert_eq!(unlocked_key.0.len(), 32); // Check if the generated key is 256 bits (32 bytes)
    }

    #[test]
    fn test_restore_success() {
        let key_bytes: [u8; 32] = [0u8; 32]; // A valid key of 32 bytes
        let unlocked_key = WalletKeyProvider::restore(&key_bytes).unwrap();
        assert_eq!(unlocked_key.0.as_slice(), &key_bytes);
    }

    #[test]
    fn test_restore_invalid_key_length() {
        let key_bytes: [u8; 16] = [0u8; 16]; // Invalid key length (should be 32 bytes)
        let result = WalletKeyProvider::restore(&key_bytes);
        assert!(result.is_err());
    }

    #[test]
    fn test_restore_base64_success() {
        let key_bytes: [u8; 32] = [0u8; 32]; // A valid 32-byte key
        let key_base64 = BASE64_STANDARD.encode(key_bytes);
        let unlocked_key = WalletKeyProvider::restore_base64(&key_base64).unwrap();
        assert_eq!(unlocked_key.0.as_slice(), &key_bytes);
    }

    #[test]
    fn test_restore_base64_invalid_key_length() {
        let key_bytes: [u8; 16] = [0u8; 16]; // Invalid key of 16 bytes
        let key_base64 = BASE64_STANDARD.encode(key_bytes);
        let result = WalletKeyProvider::restore_base64(&key_base64);
        assert!(result.is_err());
    }

    #[test]
    fn test_restore_base64_invalid_base64() {
        let invalid_base64 = "invalid_base64"; // Invalid base64 string
        let result = WalletKeyProvider::restore_base64(invalid_base64);
        assert!(result.is_err());
    }
}

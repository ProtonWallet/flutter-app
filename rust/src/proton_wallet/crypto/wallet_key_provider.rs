use aes_gcm::{
    aead::{KeyInit, OsRng},
    Aes256Gcm, Key,
};
use base64::{prelude::BASE64_STANDARD, Engine};

use super::{errors::WalletCryptoError, wallet_key::UnlockedWalletKey};

pub trait WalletKeyInterface {
    fn generate() -> UnlockedWalletKey;
    fn restore(raw_key: &[u8]) -> UnlockedWalletKey;
    fn restore_base64(key_base64: &str) -> Result<UnlockedWalletKey, WalletCryptoError>;
}

pub(crate) struct WalletKeyProvider {}

impl WalletKeyInterface for WalletKeyProvider {
    // generate a random wallet key 256 bits
    fn generate() -> UnlockedWalletKey {
        let key: Key<Aes256Gcm> = Aes256Gcm::generate_key(OsRng);
        UnlockedWalletKey(key)
    }

    // restore a wallet key from a byte array
    fn restore(key_bytes: &[u8]) -> UnlockedWalletKey {
        let key: Key<Aes256Gcm> = *Key::<Aes256Gcm>::from_slice(key_bytes);
        UnlockedWalletKey(key)
    }

    // restore wallet key from encode base64 string
    fn restore_base64(key_base64: &str) -> Result<UnlockedWalletKey, WalletCryptoError> {
        let key_bytes = BASE64_STANDARD.decode(key_base64)?;

        // Check if the decoded key length is correct (32 bytes for AES-256-GCM).
        if key_bytes.len() != 32 {
            // The key is not of the correct length. Return an error
            return Err(WalletCryptoError::AesGcmInvalidKeyLength);
        }

        let key: Key<Aes256Gcm> = *Key::<Aes256Gcm>::from_slice(&key_bytes);
        Ok(UnlockedWalletKey(key))
    }
}

use flutter_rust_bridge::frb;
use secrecy::ExposeSecret;

use super::wallet_key::FrbUnlockedWalletKey;
use crate::{
    proton_wallet::crypto::{
        mnemonic::{EncryptedWalletMnemonic, WalletMnemonic},
        wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
    },
    BridgeError,
};

pub struct FrbWalletKeyHelper {}

impl FrbWalletKeyHelper {
    #[frb(sync)]
    pub fn generate_secret_key() -> FrbUnlockedWalletKey {
        FrbUnlockedWalletKey::new(WalletKeyProvider::generate())
    }

    #[frb(sync)]
    pub fn restore(base64_secure_key: &str) -> Result<FrbUnlockedWalletKey, BridgeError> {
        Ok(FrbUnlockedWalletKey::new(
            WalletKeyProvider::restore_base64(&base64_secure_key)?,
        ))
    }

    #[frb(sync)]
    pub fn generate_secret_key_as_base64() -> String {
        WalletKeyProvider::generate().to_base64()
    }

    /// Encrypts the plaintext using AES-GCM with 256-bit key.
    #[frb(sync)]
    pub fn encrypt(base64_secure_key: String, plaintext: String) -> Result<String, BridgeError> {
        let wallet_key = WalletKeyProvider::restore_base64(&base64_secure_key)?;
        let clear_body = WalletMnemonic::new_from_str(&plaintext);
        let result = clear_body.encrypt_with(&wallet_key)?;

        Ok(result.to_base64())
    }

    /// Decrypts the encrypted text using AES-GCM with 256-bit key.
    #[frb(sync)]
    pub fn decrypt(base64_secure_key: String, encrypt_text: String) -> Result<String, BridgeError> {
        let wallet_key = WalletKeyProvider::restore_base64(&base64_secure_key)?;
        let encrypted_body = EncryptedWalletMnemonic::new_from_base64(&encrypt_text)?;
        let result = encrypted_body.decrypt_with(&wallet_key)?;
        Ok(result.as_utf8_string()?.expose_secret().to_string())
    }
}

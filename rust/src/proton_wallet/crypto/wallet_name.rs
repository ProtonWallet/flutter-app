use super::{
    binary::Binary,
    label::{EncryptedLabel, Label},
};

pub struct WalletName(Vec<u8>);
impl Binary for WalletName {
    fn new(data: Vec<u8>) -> Self {
        Self(data)
    }

    fn as_bytes(&self) -> &[u8] {
        &self.0
    }
}
impl Label for WalletName {}
pub type EncryptedWalletName = EncryptedLabel<WalletName>;

#[cfg(test)]
mod tests {
    use crate::proton_wallet::crypto::{
        binary::EncryptedBinary,
        wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
    };

    use super::*;
    use base64::{prelude::BASE64_STANDARD, Engine};

    #[test]
    fn test_label_creation_from_str() {
        let label = WalletName::new_from_str("Test wallet name");
        assert_eq!(label.as_utf8_string().unwrap(), "Test wallet name");
    }

    #[test]
    fn test_label_base64_encoding() {
        let label = WalletName::new_from_str("Test wallet name");
        assert_eq!(
            label.to_base64(),
            BASE64_STANDARD.encode("Test wallet name".as_bytes())
        );
    }

    #[test]
    fn test_label_creation_from_base64() {
        let base64_input = BASE64_STANDARD.encode("Test wallet name".as_bytes());
        let label = WalletName::new_from_base64(&base64_input).unwrap();
        assert_eq!(label.as_utf8_string().unwrap(), "Test wallet name");
    }

    #[test]
    fn test_encrypt_and_decrypt_label() {
        let wallet_key = WalletKeyProvider::generate();
        let label = WalletName::new_from_str("Sensitive Label Data");
        let encrypted_label = label.encrypt_with(&wallet_key).unwrap();
        assert_ne!(encrypted_label.as_bytes(), label.as_bytes());
        let decrypted_label = encrypted_label.decrypt_with(&wallet_key).unwrap();
        assert_ne!(
            decrypted_label.as_utf8_string().unwrap(),
            "Sensitive Label Data111"
        );
        assert_eq!(
            decrypted_label.as_utf8_string().unwrap(),
            "Sensitive Label Data"
        );
    }

    #[test]
    fn test_invalid_base64_error() {
        let invalid_base64 = "InvalidBase64!!";
        let result = WalletName::new_from_base64(invalid_base64);
        assert!(result.is_err());
    }

    #[test]
    fn test_invalid_utf8_error() {
        let invalid_utf8 = vec![0xff, 0xfe, 0xfd];
        let label = WalletName::new(invalid_utf8);
        let result = label.as_utf8_string();
        assert!(result.is_err());
    }
}

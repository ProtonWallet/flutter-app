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

impl From<String> for WalletName {
    fn from(value: String) -> Self {
        Self(value.into())
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
    fn test_wallet_name_creation_from_str() {
        let name = WalletName::new_from_str("Test wallet name");
        assert_eq!(name.as_utf8_string().unwrap(), "Test wallet name");
    }

    #[test]
    fn test_wallet_name_base64_encoding() {
        let name = WalletName::new_from_str("Test wallet name");
        assert_eq!(
            name.to_base64(),
            BASE64_STANDARD.encode("Test wallet name".as_bytes())
        );
    }

    #[test]
    fn test_wallet_name_creation_from_base64() {
        let base64_input = BASE64_STANDARD.encode("Test wallet name".as_bytes());
        let wallet_name = WalletName::new_from_base64(&base64_input).unwrap();
        assert_eq!(wallet_name.as_utf8_string().unwrap(), "Test wallet name");
    }

    #[test]
    fn test_encrypt_and_decrypt_wallet_name() {
        let wallet_key = WalletKeyProvider::generate();
        let wallet_name = WalletName::from("Sensitive wallet_name Data".to_owned());
        let encrypted_wallet_name = wallet_name.encrypt_with(&wallet_key).unwrap();
        assert_ne!(encrypted_wallet_name.as_bytes(), wallet_name.as_bytes());
        let decrypted_wallet_name = encrypted_wallet_name.decrypt_with(&wallet_key).unwrap();
        assert_ne!(
            decrypted_wallet_name.as_utf8_string().unwrap(),
            "Sensitive wallet_name Data111"
        );
        assert_eq!(
            decrypted_wallet_name.as_utf8_string().unwrap(),
            "Sensitive wallet_name Data"
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
        let wallet_name = WalletName::new(invalid_utf8);
        let result = wallet_name.as_utf8_string();
        assert!(result.is_err());
    }
}

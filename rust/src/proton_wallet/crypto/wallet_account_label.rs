use super::label::{EncryptedLabel, Label};

pub struct WalletAccountLabel(Vec<u8>);
impl Label for WalletAccountLabel {
    fn new(data: Vec<u8>) -> Self {
        Self(data)
    }

    fn as_bytes(&self) -> &[u8] {
        &self.0
    }
}

pub type EncryptedWalletAccountLabel = EncryptedLabel<WalletAccountLabel>;

#[cfg(test)]
mod tests {

    use crate::proton_wallet::crypto::wallet_key_provider::{
        WalletKeyInterface, WalletKeyProvider,
    };

    use super::*;
    use base64::{prelude::BASE64_STANDARD, Engine};

    #[test]
    fn test_label_creation_from_str() {
        let label = WalletAccountLabel::new_from_str("Test WalletAccountLabel");
        assert_eq!(label.as_utf8_string().unwrap(), "Test WalletAccountLabel");
    }

    #[test]
    fn test_label_base64_encoding() {
        let label = WalletAccountLabel::new_from_str("Test WalletAccountLabel");
        let base64 = label.to_base64();
        assert_eq!(
            base64,
            BASE64_STANDARD.encode("Test WalletAccountLabel".as_bytes())
        );
    }

    #[test]
    fn test_label_creation_from_base64() {
        let base64_input = BASE64_STANDARD.encode("Test WalletAccountLabel".as_bytes());
        let label = WalletAccountLabel::new_from_base64(&base64_input).unwrap();
        assert_eq!(label.as_utf8_string().unwrap(), "Test WalletAccountLabel");
    }

    #[test]
    fn test_encrypt_and_decrypt_label() {
        let wallet_key = WalletKeyProvider::generate();
        let label = WalletAccountLabel::new_from_str("Sensitive Label Data");

        // Encrypt the label
        let encrypted_label = label.encrypt_with(&wallet_key).unwrap();
        // Check that the data is actually encrypted
        assert_ne!(encrypted_label.as_bytes(), label.as_bytes());

        // Decrypt the label back
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
        let result = WalletAccountLabel::new_from_base64(invalid_base64);
        assert!(result.is_err());
    }

    #[test]
    fn test_invalid_utf8_error() {
        // Creating invalid UTF-8 bytes
        let invalid_utf8 = vec![0xff, 0xfe, 0xfd];
        let label = WalletAccountLabel::new(invalid_utf8);
        let result = label.as_utf8_string();
        assert!(result.is_err());
    }
}

use super::{
    binary::Binary,
    message::{EncryptedMessage, Message},
};

pub struct WalletMessage(Vec<u8>);
impl Binary for WalletMessage {
    fn new(data: Vec<u8>) -> Self {
        Self(data)
    }

    fn as_bytes(&self) -> &[u8] {
        &self.0
    }
}
impl Message for WalletMessage {}
pub type EncryptedWalletMessage = EncryptedMessage<WalletMessage>;

#[cfg(test)]
mod tests {
    use crate::{
        mocks::user_keys::tests::{
            get_test_user_2_locked_address_key, get_test_user_2_locked_user_key_secret,
            get_test_user_2_locked_user_keys, get_test_user_3_locked_user_key,
        },
        proton_wallet::crypto::{private_key::LockedPrivateKeys, public_key::PublicKeys},
    };

    use super::*;
    use base64::{prelude::BASE64_STANDARD, Engine};
    use proton_crypto::new_pgp_provider;

    #[test]
    fn test_message_creation_from_str() {
        let message = WalletMessage::new_from_str("Message body send to recipent");
        assert_eq!(
            message.as_utf8_string().unwrap(),
            "Message body send to recipent"
        );
    }

    #[test]
    fn test_message_base64_encoding() {
        let message = WalletMessage::new_from_str("Message body send to recipent");
        assert_eq!(
            message.to_base64(),
            BASE64_STANDARD.encode("Message body send to recipent".as_bytes())
        );
    }

    #[test]
    fn test_message_creation_from_base64() {
        let base64_input = BASE64_STANDARD.encode("Message body send to recipent".as_bytes());
        let message = WalletMessage::new_from_base64(&base64_input).unwrap();
        assert_eq!(
            message.as_utf8_string().unwrap(),
            "Message body send to recipent"
        );
    }

    #[test]
    fn test_invalid_base64_error() {
        let invalid_base64 = "InvalidBase64!!";
        let result = WalletMessage::new_from_base64(invalid_base64);
        assert!(result.is_err());
    }

    #[test]
    fn test_invalid_utf8_error() {
        let invalid_utf8 = vec![0xff, 0xfe, 0xfd];
        let message = WalletMessage::new(invalid_utf8);
        let result = message.as_utf8_string();
        assert!(result.is_err());
    }

    #[test]
    fn test_encrypt_and_decrypt_wallet_message() {
        let message = WalletMessage::new_from_str("Message body send to recipent");

        let provider = new_pgp_provider();
        let mut encryptor_keys = PublicKeys::default();

        let locked_address_keys = get_test_user_2_locked_address_key();
        encryptor_keys
            .add_address_keys(&provider, &locked_address_keys)
            .unwrap();

        let bad_key = get_test_user_3_locked_user_key();
        encryptor_keys
            .add_armored_key(&provider, &bad_key.private_key)
            .unwrap();

        let encrypted_label = message.encrypt_with(&provider, &encryptor_keys).unwrap();
        assert!(!encrypted_label.as_armored().unwrap().is_empty());

        let user_keys = get_test_user_2_locked_user_keys();
        let user_keys_passphase = get_test_user_2_locked_user_key_secret();
        let address_keys = get_test_user_2_locked_address_key();

        let locked_keys = LockedPrivateKeys {
            user_keys,
            addr_keys: address_keys,
        };

        let unlocked_keys = locked_keys.unlock_with(&provider, &user_keys_passphase);
        let clear = encrypted_label
            .decrypt_with(&provider, &unlocked_keys.addr_keys)
            .unwrap();
        assert_eq!(
            clear.as_utf8_string().unwrap(),
            "Message body send to recipent"
        );
    }
}

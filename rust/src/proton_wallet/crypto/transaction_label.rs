use super::label::{EncryptedLabel, Label};

pub struct TransactionLabel(Vec<u8>);
impl Label for TransactionLabel {
    fn new(data: Vec<u8>) -> Self {
        Self(data)
    }
    fn as_bytes(&self) -> &[u8] {
        &self.0
    }
}

pub type EncryptedTransactionLabel = EncryptedLabel<TransactionLabel>;

#[cfg(test)]
mod test {
    use crate::proton_wallet::crypto::{
        label::Label,
        transaction_label::{EncryptedTransactionLabel, TransactionLabel},
        wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
    };

    #[test]
    fn test_transaction_label_encrypt_decrypt() {
        let wallet_key = WalletKeyProvider::generate();
        let transaction_label_str = "Hello world";
        let trans_label = TransactionLabel::new_from_str(transaction_label_str);
        let encrypted_label = trans_label.encrypt_with(&wallet_key).unwrap();
        let output = encrypted_label.to_base64();
        assert!(!output.is_empty());

        let import_encrypted_label = EncryptedTransactionLabel::new_from_base64(&output).unwrap();
        let clear_trans_label = import_encrypted_label.decrypt_with(&wallet_key).unwrap();

        let clear_transaction_label_str = clear_trans_label.as_utf8_string().unwrap();
        assert!(clear_transaction_label_str.eq(transaction_label_str));
    }
}

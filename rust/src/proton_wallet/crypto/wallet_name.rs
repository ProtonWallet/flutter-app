use super::label::{EncryptedLabel, Label};

/// place holder
pub struct WalletName(Vec<u8>);
impl Label for WalletName {
    fn new(data: Vec<u8>) -> Self {
        Self(data)
    }

    fn as_bytes(&self) -> &[u8] {
        &self.0
    }
}

pub type EncryptedWalletName = EncryptedLabel<WalletName>;

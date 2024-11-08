use base64::{prelude::BASE64_STANDARD, Engine};
use core::str;
use proton_crypto::crypto::{
    DataEncoding, Decryptor, DecryptorSync, PGPProviderSync, VerifiedData,
};

use super::{mnemonic::EncryptedWalletMnemonic, private_key::UnlockedPrivateKeys, Result};

pub struct EncryptedWalletMnemonicLegacy {
    encoding: DataEncoding,
    pub(crate) encrypted: Vec<u8>,
}

impl EncryptedWalletMnemonicLegacy {
    pub fn new_from_base64(base64: &str) -> Result<Self> {
        let encrypted = BASE64_STANDARD.decode(base64)?;
        Ok(EncryptedWalletMnemonicLegacy {
            encrypted,
            encoding: DataEncoding::Bytes,
        })
    }
}

/// decryption
impl EncryptedWalletMnemonicLegacy {
    pub fn decrypt_with<T: PGPProviderSync>(
        &self,
        provider: &T,
        unlocked_keys: &UnlockedPrivateKeys<T>,
    ) -> Result<EncryptedWalletMnemonic> {
        Ok(EncryptedWalletMnemonic::new(
            provider
                .new_decryptor()
                .with_decryption_key_refs(unlocked_keys.user_keys.as_ref())
                .decrypt(&self.encrypted, self.encoding)?
                .to_vec(),
        ))
    }
}

#[cfg(test)]
mod tests {
    use core::str;

    use proton_crypto::new_pgp_provider;
    use proton_crypto_account::keys::AddressKeys;
    use secrecy::ExposeSecret;

    use crate::{
        mocks::user_keys::tests::{
            get_test_user_2_locked_user_key_secret, get_test_user_2_locked_user_keys,
        },
        proton_wallet::crypto::{
            mnemonic_legacy::EncryptedWalletMnemonicLegacy,
            private_key::LockedPrivateKeys,
            wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
        },
    };

    #[test]
    fn test_mnemonic_legacy() {
        // let encrypt_mnemonic_text = "-----BEGIN PGP MESSAGE-----\n\nwV4DcsIsGT18EWcSAQdAyIU6Snomx8M0mU/+QZmEdn7J2/zINdiVT6L1heMd2jgw\nRMRWvJhGciID2JTvSljSEkr8bcfmiZbIVKR0saWttDZnOFi9s4o4yf/KzrXe151/\n0m0Bs57laz4xJYeDWT7wt7mQhe/P9SriL36hFzbEDdKfc4IauAXMw7EfFp4O/if2\nZ7qBP3BrVHish5xPky9Nr6DN1WjRrp1tvC5eUrR+Yt8hp7LnHzJPpdSDUdeX/Zkd\nWObN5odksX9MrfFrxLdF\n=4j6+\n-----END PGP MESSAGE-----\n";
        let encrypted_mnemonic_text = "wV4DcsIsGT18EWcSAQdA321rKV0JcVozf2mtMHJg1CqGWYPMhSRemfAmNi7IMzUwLhXaP//ie09spnkwFSTrajBEm64yt+pvZ0w1vVEVF1hQ+hs/beMeIVUdfdfKpJqu0l4BBggwx7/DQD1F5RScfa7MdHld4+knt4mlY0wtZpi+fiwPaN7dNZ5L+dMGi1c1Ve9MYGk9QDs8czd/6Epo5cXKOWp55pSfG8wdFnMWFCSeKh8HcQ/wd3hsxyFk7+Bu";
        let encrypted_mnemonic_legacy =
            EncryptedWalletMnemonicLegacy::new_from_base64(encrypted_mnemonic_text).unwrap();
        // userkeys
        let locked_user_keys = get_test_user_2_locked_user_keys();
        let key_secret = get_test_user_2_locked_user_key_secret();
        let locked_keys = LockedPrivateKeys {
            user_keys: locked_user_keys.clone(),
            addr_keys: AddressKeys::new([]),
        };
        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_keys.unlock_with(&provider, &key_secret);

        // encrypted_mnemonic
        let encrypted_mnemonic = encrypted_mnemonic_legacy
            .decrypt_with(&provider, &unlocked_private_keys)
            .unwrap();

        // wallet key
        let base64_key = "MmI0OGRmZjQ2YzNhN2YyYmQ2NjFlNWEzNzljYTQwZGQ=";
        let wallet_key = WalletKeyProvider::restore_base64(base64_key).unwrap();
        let clean_text = encrypted_mnemonic.decrypt_with(&wallet_key).unwrap();
        let plain_text: &str = "Hello AES-256-GCM";
        assert_eq!(
            clean_text.as_utf8_string().unwrap().expose_secret(),
            plain_text
        );
    }
}

use core::str;

use super::{
    errors::WalletCryptoError, mnemonic::EncryptedWalletMnemonic, private_key::UnlockedPrivateKeys,
};

use proton_crypto::crypto::{
    DataEncoding, Decryptor, DecryptorSync, PGPProviderSync, VerifiedData,
};

pub struct EncryptedWalletMnemonicLagcy {
    pub(crate) encrypted: String,
}

impl EncryptedWalletMnemonicLagcy {
    pub fn new(armored: String) -> Self {
        EncryptedWalletMnemonicLagcy { encrypted: armored }
    }
}

/// decryption
impl EncryptedWalletMnemonicLagcy {
    pub fn decrypt_with<T: PGPProviderSync>(
        &self,
        provider: &T,
        unlocked_keys: &UnlockedPrivateKeys<T>,
    ) -> Result<EncryptedWalletMnemonic, WalletCryptoError> {
        EncryptedWalletMnemonic::new_from_base64(str::from_utf8(
            &provider
                .new_decryptor()
                .with_decryption_key_refs(unlocked_keys.user_keys.as_ref())
                .decrypt(&self.encrypted, DataEncoding::Armor)?
                .into_vec(),
        )?)
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
            mnemonic_lagcy::EncryptedWalletMnemonicLagcy,
            private_key::LockedPrivateKeys,
            wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
        },
    };

    #[test]
    fn test_mnemonic_lagcy() {
        let encrypt_mnemonic_text = "-----BEGIN PGP MESSAGE-----\n\nwV4DcsIsGT18EWcSAQdAyIU6Snomx8M0mU/+QZmEdn7J2/zINdiVT6L1heMd2jgw\nRMRWvJhGciID2JTvSljSEkr8bcfmiZbIVKR0saWttDZnOFi9s4o4yf/KzrXe151/\n0m0Bs57laz4xJYeDWT7wt7mQhe/P9SriL36hFzbEDdKfc4IauAXMw7EfFp4O/if2\nZ7qBP3BrVHish5xPky9Nr6DN1WjRrp1tvC5eUrR+Yt8hp7LnHzJPpdSDUdeX/Zkd\nWObN5odksX9MrfFrxLdF\n=4j6+\n-----END PGP MESSAGE-----\n";
        let encrypted_mnemonic_lagcy =
            EncryptedWalletMnemonicLagcy::new(encrypt_mnemonic_text.to_string());
        // userkeys
        let locked_user_keys = get_test_user_2_locked_user_keys();
        let key_secret = get_test_user_2_locked_user_key_secret();
        let locked_keys = LockedPrivateKeys {
            user_keys: locked_user_keys,
            addr_keys: AddressKeys::new([]),
        };
        let provider = new_pgp_provider();
        let unlocked_private_keys = locked_keys.unlock_with(&provider, &key_secret);

        // encrypted_mnemonic
        let encrypted_mnemonic = encrypted_mnemonic_lagcy
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

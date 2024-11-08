use std::sync::Arc;

use super::{
    user_keys::UserKeysProvider, wallet::WalletDataProvider, wallet_keys::WalletKeysProvider,
    Result,
};
use crate::proton_wallet::crypto::{
    mnemonic::{EncryptedWalletMnemonic, WalletMnemonic},
    mnemonic_legacy::EncryptedWalletMnemonicLegacy,
    private_key::LockedPrivateKeys,
};
use async_trait::async_trait;
use proton_crypto::new_pgp_provider;

#[async_trait]
pub trait WalletMnemonicProvider: Send + Sync {
    /// Retrieves the mnemonic for the wallet with the given `wallet_id`.
    /// If the wallet is marked as legacy, it decrypt with user key first then,
    /// Decrypts the encrypted mnemonic using the unlocked wallet key.
    async fn get_wallet_mnemonic(&self, wallet_id: &str) -> Result<WalletMnemonic>;
}

pub struct WalletMnemonicProviderImpl {
    pub(crate) wallet_keys_provider: Arc<dyn WalletKeysProvider>,
    pub(crate) wallet_data_provider: Arc<dyn WalletDataProvider>,
    pub(crate) user_keys_provider: Arc<dyn UserKeysProvider>,
}

impl WalletMnemonicProviderImpl {
    pub fn new(
        wallet_keys_provider: Arc<dyn WalletKeysProvider>,
        wallet_data_provider: Arc<dyn WalletDataProvider>,
        user_keys_provider: Arc<dyn UserKeysProvider>,
    ) -> Self {
        WalletMnemonicProviderImpl {
            wallet_keys_provider,
            wallet_data_provider,
            user_keys_provider,
        }
    }
}

#[async_trait]
impl WalletMnemonicProvider for WalletMnemonicProviderImpl {
    /// Retrieves the mnemonic for the wallet with the given `wallet_id`.
    /// If the wallet is marked as legacy, it decrypt with user key first then,
    /// Decrypts the encrypted mnemonic using the unlocked wallet key.
    async fn get_wallet_mnemonic(&self, wallet_id: &str) -> Result<WalletMnemonic> {
        // Fetch the wallet data using the provided `wallet_id`.
        let wallet_data = self.wallet_data_provider.get_wallet(wallet_id).await?;

        // Fetch the mnemonic associated with the wallet.
        let wallet_mnemonic = self
            .wallet_data_provider
            .get_wallet_mnemonic(wallet_id)
            .await?;

        // Fetch the unlocked wallet key.
        let unlocked_wallet_key = self
            .wallet_keys_provider
            .get_unlocked_wallet_key(wallet_id)
            .await?;

        // If the wallet is marked as legacy, handle legacy decryption.
        let encrypted_mnemonic = if wallet_data.legacy == Some(1) {
            // Handle legacy mnemonic decryption using user keys.
            let user_keys = self.user_keys_provider.get_user_keys().await?;
            let locked_private_keys = LockedPrivateKeys::from_user_keys(user_keys);
            let key_secret = self.user_keys_provider.get_user_key_passphrase().await?;

            // Unlock private keys and decrypt the legacy mnemonic.
            let provider = new_pgp_provider();
            let unlocked_private_keys = locked_private_keys.unlock_with(&provider, &key_secret);
            let legacy_mnemonic = EncryptedWalletMnemonicLegacy::new_from_base64(&wallet_mnemonic)?;
            legacy_mnemonic.decrypt_with(&provider, &unlocked_private_keys)?
        } else {
            // Handle standard mnemonic decryption.
            EncryptedWalletMnemonic::new_from_base64(&wallet_mnemonic)?
        };

        // Decrypt the encrypted mnemonic using the unlocked wallet key.
        Ok(encrypted_mnemonic.decrypt_with(&unlocked_wallet_key)?)
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
pub mod mock {
    use super::*;
    use async_trait::async_trait;
    use mockall::mock;
    mock! {
        pub WalletMnemonicProvider {}
        #[async_trait]
        impl WalletMnemonicProvider for WalletMnemonicProvider {
            async fn get_wallet_mnemonic(&self, wallet_id: &str) -> Result<WalletMnemonic>;
        }
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use super::*;
    use crate::{
        mocks::user_keys::tests::{
            get_test_user_2_locked_user_key, get_test_user_2_locked_user_key_secret,
        },
        proton_wallet::{
            crypto::{
                errors::WalletCryptoError,
                wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
            },
            db::model::wallet_model::WalletModel,
            provider::{
                error::ProviderError, user_keys::mock::MockUserKeysProvider,
                wallet::mock::MockWalletDataProvider, wallet_keys::mock::MockWalletKeysProvider,
            },
        },
    };
    use mockall::predicate::eq;
    use secrecy::ExposeSecret;
    use std::sync::Arc;

    #[tokio::test]
    async fn test_get_wallet_mnemonic_success() {
        let mut mock_keys_provider = MockWalletKeysProvider::new();
        let mut mock_data_provider = MockWalletDataProvider::new();
        let mock_user_keys_provider = MockUserKeysProvider::new();

        // Mock wallet data
        mock_data_provider
            .expect_get_wallet()
            .with(eq("wallet_id"))
            .returning(|_| {
                Ok(WalletModel {
                    legacy: Some(0),
                    ..WalletModel::default()
                })
            });
        // Mock wallet mnemonic retrieval
        mock_data_provider
            .expect_get_wallet_mnemonic()
            .with(eq("wallet_id"))
            .returning(|_| {
                Ok("dTb2Z1bsWkpo2TTCWOK09tanO3n5Ipepbj5WlCRZSuvlkEAxfePeUBCu4Qo6".to_string())
            });

        // Mock wallet key decryption
        let base64_key = "MmI0OGRmZjQ2YzNhN2YyYmQ2NjFlNWEzNzljYTQwZGQ=";
        mock_keys_provider
            .expect_get_unlocked_wallet_key()
            .with(eq("wallet_id"))
            .returning(|_| Ok(WalletKeyProvider::restore_base64(base64_key).unwrap()));

        // Mock decrypted mnemonic
        let provider = WalletMnemonicProviderImpl::new(
            Arc::new(mock_keys_provider),
            Arc::new(mock_data_provider),
            Arc::new(mock_user_keys_provider),
        );

        let result = provider.get_wallet_mnemonic("wallet_id").await.unwrap();
        let plain_text: &str = "Hello AES-256-GCM";
        assert_eq!(result.as_utf8_string().unwrap().expose_secret(), plain_text);
    }

    #[tokio::test]
    async fn test_get_legacy_wallet_mnemonic() {
        let mut mock_keys_provider = MockWalletKeysProvider::new();
        let mut mock_data_provider = MockWalletDataProvider::new();
        let mut mock_user_keys_provider = MockUserKeysProvider::new();

        // Mock legacy wallet
        mock_data_provider
            .expect_get_wallet()
            .with(eq("wallet_id"))
            .returning(|_| {
                Ok(WalletModel {
                    legacy: Some(1),
                    ..WalletModel::default()
                })
            });

        // Mock wallet mnemonic
        // let encrypt_mnemonic_text = "-----BEGIN PGP MESSAGE-----\n\nwV4DcsIsGT18EWcSAQdAyIU6Snomx8M0mU/+QZmEdn7J2/zINdiVT6L1heMd2jgw\nRMRWvJhGciID2JTvSljSEkr8bcfmiZbIVKR0saWttDZnOFi9s4o4yf/KzrXe151/\n0m0Bs57laz4xJYeDWT7wt7mQhe/P9SriL36hFzbEDdKfc4IauAXMw7EfFp4O/if2\nZ7qBP3BrVHish5xPky9Nr6DN1WjRrp1tvC5eUrR+Yt8hp7LnHzJPpdSDUdeX/Zkd\nWObN5odksX9MrfFrxLdF\n=4j6+\n-----END PGP MESSAGE-----\n";

        let encrypted_mnemonic_text = "wV4DcsIsGT18EWcSAQdA321rKV0JcVozf2mtMHJg1CqGWYPMhSRemfAmNi7IMzUwLhXaP//ie09spnkwFSTrajBEm64yt+pvZ0w1vVEVF1hQ+hs/beMeIVUdfdfKpJqu0l4BBggwx7/DQD1F5RScfa7MdHld4+knt4mlY0wtZpi+fiwPaN7dNZ5L+dMGi1c1Ve9MYGk9QDs8czd/6Epo5cXKOWp55pSfG8wdFnMWFCSeKh8HcQ/wd3hsxyFk7+Bu";
        mock_data_provider
            .expect_get_wallet_mnemonic()
            .with(eq("wallet_id"))
            .returning(|_| Ok(encrypted_mnemonic_text.to_string()));

        // Mock user keys
        mock_user_keys_provider
            .expect_get_user_keys()
            .returning(|| Ok(vec![get_test_user_2_locked_user_key()]));

        // Mock passphrase retrieval
        mock_user_keys_provider
            .expect_get_user_key_passphrase()
            .returning(|| Ok(get_test_user_2_locked_user_key_secret()));

        // Mock wallet key decryption
        let base64_key = "MmI0OGRmZjQ2YzNhN2YyYmQ2NjFlNWEzNzljYTQwZGQ=";
        mock_keys_provider
            .expect_get_unlocked_wallet_key()
            .with(eq("wallet_id"))
            .returning(|_| Ok(WalletKeyProvider::restore_base64(base64_key).unwrap()));

        let provider = WalletMnemonicProviderImpl::new(
            Arc::new(mock_keys_provider),
            Arc::new(mock_data_provider),
            Arc::new(mock_user_keys_provider),
        );

        let result = provider.get_wallet_mnemonic("wallet_id").await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_mnemonic_get_mnemonic_failure() {
        let mut mock_keys_provider = MockWalletKeysProvider::new();
        let mut mock_data_provider = MockWalletDataProvider::new();
        let mock_user_keys_provider = MockUserKeysProvider::new();

        // Mock wallet data
        mock_data_provider
            .expect_get_wallet()
            .with(eq("wallet_id"))
            .returning(|_| {
                Ok(WalletModel {
                    legacy: Some(0),
                    ..WalletModel::default()
                })
            });
        // Mock wallet mnemonic retrieval
        mock_data_provider
            .expect_get_wallet_mnemonic()
            .with(eq("wallet_id"))
            .returning(|_| Err(ProviderError::NoWalletMnemonicFound));

        // Mock wallet key decryption failure
        mock_keys_provider
            .expect_get_unlocked_wallet_key()
            .with(eq("wallet_id"))
            .returning(|_| Err(ProviderError::WalletCrypto(WalletCryptoError::NoKeysFound)));

        let provider = WalletMnemonicProviderImpl::new(
            Arc::new(mock_keys_provider),
            Arc::new(mock_data_provider),
            Arc::new(mock_user_keys_provider),
        );

        let result = provider.get_wallet_mnemonic("wallet_id").await;
        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap().to_string(),
            ProviderError::NoWalletMnemonicFound.to_string()
        );
    }

    #[tokio::test]
    async fn test_mnemonic_unlock_failure() {
        let mut mock_keys_provider = MockWalletKeysProvider::new();
        let mut mock_data_provider = MockWalletDataProvider::new();
        let mock_user_keys_provider = MockUserKeysProvider::new();

        // Mock wallet data
        mock_data_provider
            .expect_get_wallet()
            .with(eq("wallet_id"))
            .returning(|_| {
                Ok(WalletModel {
                    legacy: Some(0),
                    ..WalletModel::default()
                })
            });

        // Mock wallet mnemonic retrieval
        mock_data_provider
            .expect_get_wallet_mnemonic()
            .with(eq("wallet_id"))
            .returning(|_| {
                Ok("dTb2Z1bsWkpo2TTCWOK09tanO3n5Ipepbj5WlCRZSuvlkEAxfePeUBCu4Qo6".to_string())
            });

        // Mock wallet key decryption failure
        mock_keys_provider
            .expect_get_unlocked_wallet_key()
            .with(eq("wallet_id"))
            .returning(|_| Err(ProviderError::WalletCrypto(WalletCryptoError::NoKeysFound)));

        let provider = WalletMnemonicProviderImpl::new(
            Arc::new(mock_keys_provider),
            Arc::new(mock_data_provider),
            Arc::new(mock_user_keys_provider),
        );

        let result = provider.get_wallet_mnemonic("wallet_id").await;
        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap().to_string(),
            ProviderError::WalletCrypto(WalletCryptoError::NoKeysFound).to_string()
        );
    }

    #[tokio::test]
    async fn test_wallet_mnemonic_decrypt_failed() {
        let mut mock_keys_provider = MockWalletKeysProvider::new();
        let mut mock_data_provider = MockWalletDataProvider::new();
        let mock_user_keys_provider = MockUserKeysProvider::new();

        // Mock wallet data
        mock_data_provider
            .expect_get_wallet()
            .with(eq("wallet_id"))
            .returning(|_| {
                Ok(WalletModel {
                    legacy: Some(0),
                    ..WalletModel::default()
                })
            });
        // Mock wallet mnemonic retrieval
        mock_data_provider
            .expect_get_wallet_mnemonic()
            .with(eq("wallet_id"))
            .returning(|_| {
                Ok("dTb2Z1bsWkpo2TTCWOK09tanO3n5Ipepbj5WlCRZSuvlkEAxfePeUBCu4Qo6".to_string())
            });

        // Mock wallet key decryption
        mock_keys_provider
            .expect_get_unlocked_wallet_key()
            .with(eq("wallet_id"))
            .returning(|_| Ok(WalletKeyProvider::generate()));

        // Mock decrypted mnemonic
        let provider = WalletMnemonicProviderImpl::new(
            Arc::new(mock_keys_provider),
            Arc::new(mock_data_provider),
            Arc::new(mock_user_keys_provider),
        );

        let result = provider.get_wallet_mnemonic("wallet_id").await;
        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap().to_string(),
            ProviderError::WalletCrypto(WalletCryptoError::AesGcm("\"aead::Error\"".to_string()))
                .to_string()
                .to_string()
        );
    }
}

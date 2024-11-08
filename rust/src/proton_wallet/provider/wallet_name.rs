use async_trait::async_trait;
use std::sync::Arc;

use super::{wallet::WalletDataProvider, wallet_keys::WalletKeysProvider, Result};
use crate::proton_wallet::crypto::{
    binary::{Binary, EncryptedBinary},
    wallet_name::EncryptedWalletName,
};

#[async_trait]
pub trait WalletNameProvider: Send + Sync {
    async fn get_wallet_name(&self, wallet_id: &str) -> Result<String>;
}

pub struct WalletNameProviderImpl {
    pub(crate) wallet_keys_provider: Arc<dyn WalletKeysProvider>,
    pub(crate) wallet_data_provider: Arc<dyn WalletDataProvider>,
}

impl WalletNameProviderImpl {
    pub fn new(
        wallet_keys_provider: Arc<dyn WalletKeysProvider>,
        wallet_data_provider: Arc<dyn WalletDataProvider>,
    ) -> Self {
        WalletNameProviderImpl {
            wallet_keys_provider,
            wallet_data_provider,
        }
    }
}

#[async_trait]
impl WalletNameProvider for WalletNameProviderImpl {
    async fn get_wallet_name(&self, wallet_id: &str) -> Result<String> {
        // Fetch the wallet data using the provided `wallet_id`.
        let wallet_data = self.wallet_data_provider.get_wallet(wallet_id).await?;

        // Fetch the unlocked wallet key.
        let unlocked_wallet_key = self
            .wallet_keys_provider
            .get_unlocked_wallet_key(wallet_id)
            .await?;

        // Handle standard wallet name decryption.
        let encrypted_name = EncryptedWalletName::new_from_base64(&wallet_data.name)?;

        // Decrypt the encrypted wallet name using the unlocked wallet key.
        let clear_name = encrypted_name.decrypt_with(&unlocked_wallet_key)?;
        Ok(clear_name.as_utf8_string()?)
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
pub mod mock {
    use super::*;
    use async_trait::async_trait;
    use mockall::mock;
    mock! {
        pub WalletNameProvider {}
        #[async_trait]
        impl WalletNameProvider for WalletNameProvider {
            async fn get_wallet_name(&self, wallet_id: &str) -> Result<String>;
        }
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use super::*;
    use crate::proton_wallet::{
        crypto::{
            errors::WalletCryptoError,
            label::Label,
            wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
            wallet_name::WalletName,
        },
        db::model::wallet_model::WalletModel,
        provider::{
            error::ProviderError, wallet::mock::MockWalletDataProvider,
            wallet_keys::mock::MockWalletKeysProvider,
        },
    };
    use mockall::predicate::eq;
    use std::sync::Arc;

    #[tokio::test]
    async fn test_get_wallet_name_success() {
        let mut mock_keys_provider = MockWalletKeysProvider::new();
        let mut mock_data_provider = MockWalletDataProvider::new();

        let mock_wallet_key = WalletKeyProvider::generate();
        let label = WalletName::new_from_str("Sensitive Name Data");
        let encrypted_label = label.encrypt_with(&mock_wallet_key).unwrap();
        // Mock WalletModel data
        let wallet_data = WalletModel {
            wallet_id: "wallet_id".to_string(),
            name: encrypted_label.to_base64(),
            ..WalletModel::default()
        };
        // Set expectations for mock providers
        mock_data_provider
            .expect_get_wallet()
            .with(eq("wallet_id"))
            .returning(move |_| Ok(wallet_data.clone()));

        mock_keys_provider
            .expect_get_unlocked_wallet_key()
            .with(eq("wallet_id"))
            .returning(move |_| Ok(mock_wallet_key.clone()));

        let provider =
            WalletNameProviderImpl::new(Arc::new(mock_keys_provider), Arc::new(mock_data_provider));

        let result = provider.get_wallet_name("wallet_id").await.unwrap();
        assert_eq!(result, "Sensitive Name Data"); // replace with actual expected name
    }

    #[tokio::test]
    async fn test_get_wallet_name_failure_no_key() {
        let mut mock_keys_provider = MockWalletKeysProvider::new();
        let mut mock_data_provider = MockWalletDataProvider::new();

        // Mock WalletModel data
        let wallet_data = WalletModel {
            name: "encrypted_name_base64".to_string(),
            ..WalletModel::default()
        };

        mock_data_provider
            .expect_get_wallet()
            .with(eq("wallet_id"))
            .returning(move |_| Ok(wallet_data.clone()));

        // Simulate failure in key retrieval
        mock_keys_provider
            .expect_get_unlocked_wallet_key()
            .with(eq("wallet_id"))
            .returning(move |_| Err(WalletCryptoError::NoKeysFound.into()));

        let provider =
            WalletNameProviderImpl::new(Arc::new(mock_keys_provider), Arc::new(mock_data_provider));

        let result = provider.get_wallet_name("wallet_id").await;
        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap().to_string(),
            ProviderError::WalletCrypto(WalletCryptoError::NoKeysFound).to_string()
        );
    }

    #[tokio::test]
    async fn test_get_wallet_name_decryption_error() {
        let mut mock_keys_provider = MockWalletKeysProvider::new();
        let mut mock_data_provider = MockWalletDataProvider::new();

        let mock_wallet_key = WalletKeyProvider::generate();
        let label = WalletName::new_from_str("Sensitive Name Data");
        let encrypted_label = label.encrypt_with(&mock_wallet_key).unwrap();
        // Mock WalletModel data
        let wallet_data = WalletModel {
            wallet_id: "wallet_id".to_string(),
            name: encrypted_label.to_base64(),
            ..WalletModel::default()
        };

        mock_data_provider
            .expect_get_wallet()
            .with(eq("wallet_id"))
            .returning(move |_| Ok(wallet_data.clone()));

        let mock_unlocked_key =
            WalletKeyProvider::restore_base64("MmI0OGRmZjQ2YzNhN2YyYmQ2NjFlNWEzNzljYTQwZGQ=")
                .unwrap();
        mock_keys_provider
            .expect_get_unlocked_wallet_key()
            .with(eq("wallet_id"))
            .returning(move |_| Ok(mock_unlocked_key.clone()));

        let provider =
            WalletNameProviderImpl::new(Arc::new(mock_keys_provider), Arc::new(mock_data_provider));

        let result = provider.get_wallet_name("wallet_id").await;
        assert!(result.is_err());
        assert!(result
            .err()
            .unwrap()
            .to_string()
            .contains("Aes gcm crypto error:"));
    }
}

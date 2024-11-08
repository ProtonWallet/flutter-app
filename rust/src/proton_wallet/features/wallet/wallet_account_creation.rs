use andromeda_api::{
    wallet::{ApiWalletAccount, CreateWalletAccountRequestBody},
    wallet_ext::WalletClientExt,
};
use std::sync::Arc;

use super::Result;
use crate::proton_wallet::{
    crypto::{
        binary::{Binary, EncryptedBinary},
        label::Label,
        wallet_account_label::WalletAccountLabel,
    },
    provider::{wallet::WalletDataProvider, wallet_keys::WalletKeysProvider},
};

pub struct WalletAccountCreation {
    pub(crate) wallet_client: Arc<dyn WalletClientExt>,
    pub(crate) wallet_data_provider: Arc<dyn WalletDataProvider>,
    pub(crate) wallet_key_provider: Arc<dyn WalletKeysProvider>,
}

impl WalletAccountCreation {
    pub async fn create_wallet_account(
        &self,
        wallet_id: &str,
        script_type: u8,
        label: &str,
        bip_version: u32,
        coin_type: u32,
    ) -> Result<ApiWalletAccount> {
        // Initialize label encryption
        let clear_label = WalletAccountLabel::new_from_str(label);
        let unlocked_wallet_key = self
            .wallet_key_provider
            .get_unlocked_wallet_key(wallet_id)
            .await?;
        let encrypted_label = clear_label.encrypt_with(&unlocked_wallet_key)?;

        // Generate derivation path
        let derivation_path = self
            .wallet_data_provider
            .get_new_derivation_path(wallet_id, bip_version, coin_type)
            .await?;

        // Prepare API request for wallet account creation
        let request = CreateWalletAccountRequestBody {
            DerivationPath: derivation_path,
            Label: encrypted_label.to_base64(),
            ScriptType: script_type,
        };

        // Send request and return the API response
        self.wallet_client
            .create_wallet_account(wallet_id.to_string(), request)
            .await
            .map_err(Into::into)
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use super::*;
    use crate::proton_wallet::{
        crypto::wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
        provider::{
            wallet::mock::MockWalletDataProvider, wallet_keys::mock::MockWalletKeysProvider,
        },
    };
    use andromeda_api::{
        tests::wallet_mock::mock_utils::MockWalletClient, wallet::ApiWalletAccount,
    };
    use std::sync::Arc;

    #[tokio::test]
    async fn test_create_wallet_account_success() {
        let mut mock_wallet_client = MockWalletClient::new();
        let mut mock_wallet_data_provider = MockWalletDataProvider::new();
        let mut mock_wallet_key_provider = MockWalletKeysProvider::new();

        // Setup mocks
        mock_wallet_client
            .expect_create_wallet_account()
            .returning(|_, _| {
                Ok(ApiWalletAccount {
                    ID: "test_account_id".into(),
                    ..Default::default()
                })
            });

        mock_wallet_data_provider
            .expect_get_new_derivation_path()
            .returning(|_, _, _| Ok("m/44'/0'/0'/0".into()));

        // Mock wallet key decryption
        let base64_key = "MmI0OGRmZjQ2YzNhN2YyYmQ2NjFlNWEzNzljYTQwZGQ=";
        mock_wallet_key_provider
            .expect_get_unlocked_wallet_key()
            .returning(|_| Ok(WalletKeyProvider::restore_base64(base64_key).unwrap()));

        let wallet_creation = WalletAccountCreation {
            wallet_client: Arc::new(mock_wallet_client),
            wallet_data_provider: Arc::new(mock_wallet_data_provider),
            wallet_key_provider: Arc::new(mock_wallet_key_provider),
        };

        let result = wallet_creation
            .create_wallet_account("wallet_id", 0, "My Label", 44, 0)
            .await
            .expect("Wallet account creation should succeed");

        assert_eq!(result.ID, "test_account_id");
    }

    #[tokio::test]
    async fn test_create_wallet_account_failure() {
        let mut mock_wallet_client = MockWalletClient::new();
        let mut mock_wallet_data_provider = MockWalletDataProvider::new();
        let mut mock_wallet_key_provider = MockWalletKeysProvider::new();

        // Simulate failure in creating wallet account
        mock_wallet_client
            .expect_create_wallet_account()
            .returning(|_, _| Err(andromeda_api::error::Error::Http));

        mock_wallet_data_provider
            .expect_get_new_derivation_path()
            .returning(|_, _, _| Ok("m/44'/0'/0'/0".into()));

        // Mock wallet key decryption
        let base64_key = "MmI0OGRmZjQ2YzNhN2YyYmQ2NjFlNWEzNzljYTQwZGQ=";
        mock_wallet_key_provider
            .expect_get_unlocked_wallet_key()
            .returning(|_| Ok(WalletKeyProvider::restore_base64(base64_key).unwrap()));

        let wallet_creation = WalletAccountCreation {
            wallet_client: Arc::new(mock_wallet_client),
            wallet_data_provider: Arc::new(mock_wallet_data_provider),
            wallet_key_provider: Arc::new(mock_wallet_key_provider),
        };

        let result = wallet_creation
            .create_wallet_account("wallet_id", 0, "My Label", 44, 0)
            .await;

        assert!(result.is_err());
    }
}

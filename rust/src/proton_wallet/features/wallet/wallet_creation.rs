use andromeda_api::{
    wallet::{ApiWalletData, CreateWalletRequestBody},
    wallet_ext::WalletClientExt,
};
use proton_crypto_account::proton_crypto::new_pgp_provider;
use std::sync::Arc;

use super::Result;
use crate::proton_wallet::{
    crypto::{
        binary::{Binary, EncryptedBinary},
        label::Label,
        mnemonic::WalletMnemonic,
        private_key::LockedPrivateKeys,
        wallet_key_provider::{WalletKeyInterface, WalletKeyProvider as CryptoWalletKeyProvider},
        wallet_name::WalletName,
    },
    features::error::FeaturesError,
    provider::user_keys::UserKeysProvider,
};

pub struct WalletCreation {
    pub(crate) wallet_client: Arc<dyn WalletClientExt>,
    pub(crate) user_keys_provider: Arc<dyn UserKeysProvider>,
}

impl WalletCreation {
    /// Creates a new wallet
    ///
    /// This function generates a wallet secret key, encrypts the wallet's mnemonic
    /// and name, and encrypts the wallet key with the user's private key.
    /// It also signs the wallet key, sends the wallet creation request to the server
    ///
    /// # Arguments
    ///
    /// * `wallet_name` - The name of the wallet to be created.
    /// * `mnemonic_str` - The mnemonic string used for wallet creation.
    /// * `network` - The blockchain network to which the wallet belongs.
    /// * `wallet_type` - An integer representing the type of wallet.
    /// * `wallet_passphrase` - An optional passphrase for additional encryption.
    ///
    /// # Returns
    ///
    /// A `Result` containing the `ApiWalletData` if successful, or an error if the
    /// operation fails.
    ///
    /// # Errors
    ///
    /// This function will return an error if any step in the wallet creation process
    /// fails, such as key generation, encryption, or communication with the server.
    pub async fn create_wallet(
        &self,
        key_id: String,
        wallet_name: String,
        mnemonic_str: String,
        fingerprint: String,
        wallet_type: u8,
        wallet_passphrase: Option<String>,
    ) -> Result<ApiWalletData> {
        // check if primary_user_key has a primary user key

        // Generate a wallet secret key
        let wallet_key = CryptoWalletKeyProvider::generate();

        // Encrypt mnemonic with wallet key
        let encrypted_mnemonic = WalletMnemonic::new_from_str(&mnemonic_str)
            .encrypt_with(&wallet_key)?
            .to_base64();

        // Select wallet name
        let selected_wallet_name = if !wallet_name.is_empty() {
            wallet_name.to_string()
        } else {
            "My Wallet".to_string()
        };

        // Encrypt wallet name with wallet key
        let encrypted_wallet_name = WalletName::new_from_str(&selected_wallet_name)
            .encrypt_with(&wallet_key)?
            .to_base64();

        // Encrypt wallet key with user private key
        let provider = new_pgp_provider();
        let locked_user_key =
            LockedPrivateKeys::from_primary(self.user_keys_provider.get_primary_key().await?);
        let user_key_passphrase = self.user_keys_provider.get_user_key_passphrase().await?;
        let unlocked = locked_user_key.unlock_with(&provider, &user_key_passphrase);
        let first_key = unlocked
            .user_keys
            .first()
            .ok_or(FeaturesError::NoUnlockedUserKeyFound)?;
        let encrypted = wallet_key.lock_with(&provider, first_key)?;

        let wallet_req = CreateWalletRequestBody {
            Name: encrypted_wallet_name,
            IsImported: wallet_type,
            Type: 1,
            HasPassphrase: wallet_passphrase.is_some() as u8,
            UserKeyID: key_id,
            WalletKey: encrypted.get_armored(),
            WalletKeySignature: encrypted.get_signature(),
            Mnemonic: Some(encrypted_mnemonic),
            Fingerprint: Some(fingerprint),
            PublicKey: None,
            IsAutoCreated: 0,
        };

        self.wallet_client
            .create_wallet(wallet_req)
            .await
            .map_err(Into::into)
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use crate::{
        mocks::user_keys::tests::{
            get_test_user_1_locked_user_key, get_test_user_1_locked_user_key_secret,
        },
        proton_wallet::provider::{error::ProviderError, user_keys::mock::MockUserKeysProvider},
    };

    use super::*;
    use andromeda_api::{tests::wallet_mock::mock_utils::MockWalletClient, wallet::ApiWallet};

    #[tokio::test]
    async fn test_create_wallet_success() {
        let mut mock_wallet_client = MockWalletClient::new();
        let mut mock_user_keys_provider = MockUserKeysProvider::new();

        // Setup mock wallet client to simulate successful wallet creation
        mock_wallet_client.expect_create_wallet().returning(|_| {
            Ok(ApiWalletData {
                Wallet: ApiWallet {
                    Name: "My Test Wallet".to_string(),
                    ..Default::default()
                },
                ..Default::default()
            })
        });

        // Setup mock user keys provider for primary key and passphrase
        mock_user_keys_provider
            .expect_get_primary_key()
            .returning(|| Ok(get_test_user_1_locked_user_key().0.first().unwrap().clone()));
        mock_user_keys_provider
            .expect_get_user_key_passphrase()
            .returning(|| Ok(get_test_user_1_locked_user_key_secret()));

        let wallet_creation = WalletCreation {
            wallet_client: Arc::new(mock_wallet_client),
            user_keys_provider: Arc::new(mock_user_keys_provider),
        };

        // Execute wallet creation
        let result = wallet_creation
            .create_wallet(
                "key_id_123".to_string(),
                "My Test Wallet".to_string(),
                "test mnemonic".to_string(),
                "test_fingerprint".to_string(),
                1,
                None,
            )
            .await
            .expect("Wallet creation should succeed");

        assert_eq!(result.Wallet.Name, "My Test Wallet");
    }

    #[tokio::test]
    async fn test_create_wallet_user_key_error() {
        let mut mock_wallet_client = MockWalletClient::new();
        let mut mock_user_keys_provider = MockUserKeysProvider::new();

        // Setup mock wallet client to simulate failure
        mock_wallet_client
            .expect_create_wallet()
            .returning(|_| Err(andromeda_api::error::Error::Http));

        // Simulate error in retrieving primary key from user keys provider
        mock_user_keys_provider
            .expect_get_primary_key()
            .returning(|| Err(ProviderError::NoUserKeysFound));

        let wallet_creation = WalletCreation {
            wallet_client: Arc::new(mock_wallet_client),
            user_keys_provider: Arc::new(mock_user_keys_provider),
        };

        // Execute wallet creation and expect failure due to missing primary key
        let result = wallet_creation
            .create_wallet(
                "key_id_123".to_string(),
                "Test Wallet".to_string(),
                "test mnemonic".to_string(),
                "test_fingerprint".to_string(),
                1,
                None,
            )
            .await;

        assert!(result.is_err());
        assert_eq!(
            result.unwrap_err().to_string(),
            "Wallet provider error: User key not found"
        );
    }

    #[tokio::test]
    async fn test_create_wallet_encryption_failure() {
        let mut mock_wallet_client = MockWalletClient::new();
        let mut mock_user_keys_provider = MockUserKeysProvider::new();

        // Setup mock wallet client for successful API call
        mock_wallet_client
            .expect_create_wallet()
            .returning(|_| Err(andromeda_api::error::Error::Http));

        // Setup mock user keys provider for primary key and passphrase
        mock_user_keys_provider
            .expect_get_primary_key()
            .returning(|| Ok(get_test_user_1_locked_user_key().0.first().unwrap().clone()));
        mock_user_keys_provider
            .expect_get_user_key_passphrase()
            .returning(|| Ok(get_test_user_1_locked_user_key_secret()));

        let wallet_creation = WalletCreation {
            wallet_client: Arc::new(mock_wallet_client),
            user_keys_provider: Arc::new(mock_user_keys_provider),
        };

        // Execute wallet creation and expect failure due to encryption issue
        let result = wallet_creation
            .create_wallet(
                "key_id_123".to_string(),
                "Failing Wallet".to_string(),
                "test mnemonic".to_string(),
                "test_fingerprint".to_string(),
                1,
                None,
            )
            .await;

        assert!(result.is_err());
        assert_eq!(
            result.unwrap_err().to_string(),
            "Andromeda api error: HTTP error"
        );
    }
}

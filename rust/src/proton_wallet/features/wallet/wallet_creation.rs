#![allow(dead_code)] // temperay allow dead code
use std::sync::Arc;

use andromeda_api::{
    wallet::{
        ApiWalletAccount, ApiWalletData, CreateWalletAccountRequestBody, CreateWalletRequestBody,
    },
    wallet_ext::WalletClientExt,
};
use proton_crypto_account::{keys::UserKeys, proton_crypto::new_pgp_provider, salts::KeySecret};

use crate::proton_wallet::{
    crypto::{
        binary::Binary,
        mnemonic::WalletMnemonic,
        wallet_account_label::WalletAccountLabel,
        wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
    },
    features::error::FeaturesError,
};

pub struct WalletCreation<T: WalletClientExt> {
    wallet_client: Arc<T>,
}

impl<T: WalletClientExt> WalletCreation<T> {
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
    async fn create_wallet(
        &self,
        key_id: String,
        primary_user_key: &UserKeys,
        user_key_passphrase: &KeySecret,
        wallet_name: String,
        mnemonic_str: String,
        fingerprint: String,
        wallet_type: u8,
        wallet_passphrase: Option<String>,
    ) -> Result<ApiWalletData, FeaturesError> {
        // check if primary_user_key has a primary user key

        // Generate a wallet secret key
        let secret_key = WalletKeyProvider::generate();

        // Encrypt mnemonic with wallet key
        let clear_mnemonic_body = WalletMnemonic::new_from_str(&mnemonic_str);
        let result = clear_mnemonic_body.encrypt_with(&secret_key)?;
        let base64_encrypted_mnemonic = result.to_base64();

        // Encrypt wallet name with wallet key
        let clear_wallet_name = if !wallet_name.is_empty() {
            wallet_name.to_string()
        } else {
            "My Wallet".to_string()
        };
        let clear_wallet_namne_body = WalletMnemonic::new_from_str(&clear_wallet_name);
        let result = clear_wallet_namne_body.encrypt_with(&secret_key)?;
        let base64_encrypted_wallet_name = result.to_base64();

        // Encrypt wallet key with user private key
        let provider = new_pgp_provider();
        let unlocked = primary_user_key.unlock(&provider, user_key_passphrase);
        let first = unlocked.unlocked_keys.first().unwrap();
        let encrypted = secret_key.lock_with(&provider, first)?;

        let wallet_req = CreateWalletRequestBody {
            Name: base64_encrypted_wallet_name,
            IsImported: wallet_type,
            Type: 1,
            HasPassphrase: wallet_passphrase.is_some() as u8,
            UserKeyID: key_id,
            WalletKey: encrypted.get_armored(),
            WalletKeySignature: encrypted.get_signature(),
            Mnemonic: Some(base64_encrypted_mnemonic),
            Fingerprint: Some(fingerprint),
            PublicKey: None,
            IsAutoCreated: 0,
        };

        let wallet_data = self.wallet_client.create_wallet(wallet_req).await?;
        Ok(wallet_data)
    }

    pub async fn create_wallet_account(
        &self,
        wallet_id: String,
        // script_type: &ScriptTypeInfo,
        label: String,
        // fiat_currency: &FiatCurrency,
        account_index: i32,
    ) -> Result<ApiWalletAccount, FeaturesError> {
        let clear_label = WalletAccountLabel::new_from_str(&label);

        // Create request
        let request = CreateWalletAccountRequestBody {
            DerivationPath: "".to_owned(),
            Label: "".to_owned(),
            ScriptType: 1,
        };

        let api_wallet_account = self
            .wallet_client
            .create_wallet_account(wallet_id, request)
            .await?;
        Ok(api_wallet_account)
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod test {
    use std::sync::Arc;

    use andromeda_api::{tests::wallet_mock::mock_utils::MockWalletClient, wallet::ApiWalletData};

    use crate::{
        mocks::user_keys::tests::{
            get_test_user_1_locked_user_key, get_test_user_1_locked_user_key_secret,
        },
        proton_wallet::features::wallet::wallet_creation::WalletCreation,
    };

    #[tokio::test]
    async fn test_create_wallet_success() {
        let user_keys = get_test_user_1_locked_user_key();
        let key_secret = get_test_user_1_locked_user_key_secret();
        let mut mock_client = MockWalletClient::new();
        mock_client.expect_create_wallet().returning({
            |req| {
                let mut out = ApiWalletData::default();
                out.Wallet.Name = req.Name;
                out.WalletKey.UserKeyID = req.UserKeyID;
                out.WalletKey.WalletKey = req.WalletKey;
                out.WalletKey.WalletKeySignature = req.WalletKeySignature;
                Ok(out)
            }
        });
        let wallet_creation = WalletCreation {
            wallet_client: Arc::new(mock_client),
        };
        let result = wallet_creation
            .create_wallet(
                "aTdvCsWuv2V_YQQ5nLKsWPkHWMrlHfUxL9aTWakz6blhwI0q_j4MKnxO29xMQ4slCRvo3lFLE8ljb3kvMP2PQQ==".to_string(),
                &user_keys,
                &key_secret,
                "My Wallet".to_string(),
                "dummy_mnemonic".to_string(),
                "dummy_fingerprint".to_string(),
                1,
                None,
            )
            .await
            .unwrap();
        assert_eq!(result.WalletKey.UserKeyID, "aTdvCsWuv2V_YQQ5nLKsWPkHWMrlHfUxL9aTWakz6blhwI0q_j4MKnxO29xMQ4slCRvo3lFLE8ljb3kvMP2PQQ==");
    }

    #[tokio::test]
    async fn test_create_wallet_fail_encryption() {}
}

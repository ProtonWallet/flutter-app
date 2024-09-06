#![allow(dead_code)] // temperay allow dead code
use std::sync::Arc;

use andromeda_api::wallet::{ApiWalletData, CreateWalletRequestBody, WalletClient};

use crate::proton_wallet::{
    crypto::{
        mnemonic::WalletMnemonic,
        wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
    },
    features::error::FeaturesError,
    storage::user_key::UserKeyStorage,
};

pub struct WalletCreation {
    user_key_storage: Arc<UserKeyStorage>,
    wallet_client: Arc<WalletClient>,
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
    async fn create_wallet(
        &self,
        wallet_name: String,
        mnemonic_str: String,
        fingerprint: String,
        wallet_type: u8,
        wallet_passphrase: Option<String>,
    ) -> Result<ApiWalletData, FeaturesError> {
        // Generate a wallet secret key
        let secret_key = WalletKeyProvider::generate();
        // let entropy = secret_key.as_entropy();

        // Get the first user key (primary user key) after used release them
        // let primary_user_key = user_manager::get_primary_key().await?;
        // let user_private_key = primary_user_key.private_key.clone();
        // let user_key_id = primary_user_key.key_id.clone();
        // let passphrase = primary_user_key.passphrase.clone();

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
        // let encrypted_wallet_key = proton_crypto::encrypt_binary_armor(&user_private_key, &entropy)?;

        // Sign wallet key with user private key
        // let wallet_key_signature = proton_crypto::get_binary_signature_with_context(
        //     &user_private_key,
        //     &passphrase,
        //     &entropy,
        //     gpg_context_wallet_key,
        // )?;

        let wallet_req = CreateWalletRequestBody {
            Name: base64_encrypted_wallet_name,
            IsImported: wallet_type,
            Type: 1,
            HasPassphrase: wallet_passphrase.is_some() as u8,
            UserKeyID: "KeyID".to_string(),
            WalletKey: "Encrypted wallet key".to_string(),
            WalletKeySignature: "Encrypted wallet key signature".to_string(),
            Mnemonic: Some(base64_encrypted_mnemonic),
            Fingerprint: Some(fingerprint),
            PublicKey: None,
            IsAutoCreated: 0,
        };

        let wallet_data = self.wallet_client.create_wallet(wallet_req).await?;
        Ok(wallet_data)
    }
}

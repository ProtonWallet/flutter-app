use secrecy::ExposeSecret;
use std::sync::Arc;

use super::{proton_settings::password_scope::PasswordScope, Result};
use crate::proton_wallet::provider::{
    proton_auth::ProtonAuthProvider, wallet_mnemonic::WalletMnemonicProvider,
    wallet_name::WalletNameProvider,
};

pub struct MnemonicResult {
    pub wallet_id: String,
    pub wallet_name: String,
    pub wallet_mnemonic: String,
}

pub struct BackupMnemonic {
    pub(crate) auth_provider: Arc<dyn ProtonAuthProvider>,
    pub(crate) wallet_mnemonic_provider: Arc<dyn WalletMnemonicProvider>,
    pub(crate) wallet_name_provider: Arc<dyn WalletNameProvider>,
    ///feature dependency
    pub(crate) unlock_password: Arc<dyn PasswordScope>,
}

impl BackupMnemonic {
    pub async fn two_fa_status(&self) -> Result<u8> {
        let auth_info = self.auth_provider.auth_info().await?;
        Ok(auth_info.two_fa.Enabled)
    }

    pub async fn view_seed(
        &self,
        wallet_id: String,
        login_password: &str,
        twofa: &str,
    ) -> Result<MnemonicResult> {
        // unlock password scope
        self.unlock_password
            .unlock_password_change(login_password, twofa)
            .await?;

        // Get mnemonic with wallet ID and split it
        let str_mnemonic = self
            .wallet_mnemonic_provider
            .get_wallet_mnemonic(&wallet_id)
            .await?;

        // Try to get wallet name, with fallback to "Unknown"
        let wallet_name = self
            .wallet_name_provider
            .get_wallet_name(&wallet_id)
            .await?;

        Ok(MnemonicResult {
            wallet_id,
            wallet_name,
            wallet_mnemonic: str_mnemonic.as_utf8_string()?.expose_secret().to_string(),
        })
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use super::*;
    use crate::proton_wallet::{
        crypto::{errors::WalletCryptoError, mnemonic::WalletMnemonic},
        features::{
            error::FeaturesError, proton_settings::password_scope::mock::MockPasswordScope,
        },
        provider::{
            error::ProviderError, proton_auth::mock::MockProtonAuthProvider,
            wallet_mnemonic::mock::MockWalletMnemonicProvider,
            wallet_name::mock::MockWalletNameProvider,
        },
    };
    use andromeda_api::proton_users::{GetAuthInfoResponseBody, TwoFA};
    use std::sync::Arc;

    fn setup_mocks() -> (
        MockProtonAuthProvider,
        MockWalletMnemonicProvider,
        MockWalletNameProvider,
        MockPasswordScope,
    ) {
        (
            MockProtonAuthProvider::new(),
            MockWalletMnemonicProvider::new(),
            MockWalletNameProvider::new(),
            MockPasswordScope::new(),
        )
    }

    #[tokio::test]
    async fn test_two_fa_status_enabled() {
        let (mut mock_auth_provider, _, _, _) = setup_mocks();

        let auth_info = GetAuthInfoResponseBody {
            two_fa: TwoFA { Enabled: 1 },
            ..Default::default()
        };

        mock_auth_provider
            .expect_auth_info()
            .times(1)
            .returning(move || Ok(auth_info.clone()));

        let backup_mnemonic = BackupMnemonic {
            auth_provider: Arc::new(mock_auth_provider),
            wallet_mnemonic_provider: Arc::new(MockWalletMnemonicProvider::new()),
            wallet_name_provider: Arc::new(MockWalletNameProvider::new()),
            unlock_password: Arc::new(MockPasswordScope::new()),
        };

        let result = backup_mnemonic.two_fa_status().await.unwrap();
        assert_eq!(result, 1);
    }

    #[tokio::test]
    async fn test_two_fa_status_disabled() {
        let (mut mock_auth_provider, _, _, _) = setup_mocks();

        let auth_info = GetAuthInfoResponseBody {
            two_fa: TwoFA { Enabled: 0 },
            ..Default::default()
        };

        mock_auth_provider
            .expect_auth_info()
            .times(1)
            .returning(move || Ok(auth_info.clone()));

        let backup_mnemonic = BackupMnemonic {
            auth_provider: Arc::new(mock_auth_provider),
            wallet_mnemonic_provider: Arc::new(MockWalletMnemonicProvider::new()),
            wallet_name_provider: Arc::new(MockWalletNameProvider::new()),
            unlock_password: Arc::new(MockPasswordScope::new()),
        };

        let result = backup_mnemonic.two_fa_status().await.unwrap();
        assert_eq!(result, 0);
    }

    #[tokio::test]
    async fn test_view_seed_success() {
        let (_, mut mock_mnemonic_provider, mut mock_name_provider, mut mock_password_scope) =
            setup_mocks();

        mock_password_scope
            .expect_unlock_password_change()
            .withf(|password, twofa| password == "correct_password" && twofa == "123456")
            .returning(|_, _| Ok(()));

        mock_mnemonic_provider
            .expect_get_wallet_mnemonic()
            .withf(|wallet_id| wallet_id == "wallet123")
            .returning(|_| Ok(WalletMnemonic::new_from_str("dummy_mnemonic")));

        mock_name_provider
            .expect_get_wallet_name()
            .withf(|wallet_id| wallet_id == "wallet123")
            .returning(|_| Ok("My Wallet".to_string()));

        let backup_mnemonic = BackupMnemonic {
            auth_provider: Arc::new(MockProtonAuthProvider::new()),
            wallet_mnemonic_provider: Arc::new(mock_mnemonic_provider),
            wallet_name_provider: Arc::new(mock_name_provider),
            unlock_password: Arc::new(mock_password_scope),
        };

        let result = backup_mnemonic
            .view_seed("wallet123".to_string(), "correct_password", "123456")
            .await
            .unwrap();

        assert_eq!(result.wallet_id, "wallet123");
        assert_eq!(result.wallet_name, "My Wallet");
        assert_eq!(result.wallet_mnemonic, "dummy_mnemonic");
    }

    #[tokio::test]
    async fn test_view_seed_unlock_failure() {
        let (_, _, _, mut mock_password_scope) = setup_mocks();

        mock_password_scope
            .expect_unlock_password_change()
            .returning(|_, _| Err(FeaturesError::InvalidSrpServerProofs));

        let backup_mnemonic = BackupMnemonic {
            auth_provider: Arc::new(MockProtonAuthProvider::new()),
            wallet_mnemonic_provider: Arc::new(MockWalletMnemonicProvider::new()),
            wallet_name_provider: Arc::new(MockWalletNameProvider::new()),
            unlock_password: Arc::new(mock_password_scope),
        };

        let result = backup_mnemonic
            .view_seed("wallet123".to_string(), "wrong_password", "123456")
            .await;

        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap().to_string(),
            "Invalid srp server proofs"
        );
    }

    #[tokio::test]
    async fn test_view_seed_get_wallet_mnemonic_failure() {
        let (_, mut mock_wallet_mnemonic, _, mut mock_password_scope) = setup_mocks();
        mock_password_scope
            .expect_unlock_password_change()
            .returning(|_, _| Ok(()));

        mock_wallet_mnemonic
            .expect_get_wallet_mnemonic()
            .returning(|_| Err(ProviderError::NoWalletKeysFound));

        let backup_mnemonic = BackupMnemonic {
            auth_provider: Arc::new(MockProtonAuthProvider::new()),
            wallet_mnemonic_provider: Arc::new(mock_wallet_mnemonic),
            wallet_name_provider: Arc::new(MockWalletNameProvider::new()),
            unlock_password: Arc::new(mock_password_scope),
        };
        let result = backup_mnemonic
            .view_seed("wallet123".to_string(), "wrong_password", "123456")
            .await;

        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap().to_string(),
            "Wallet provider error: Wallet key not found"
        );
    }

    #[tokio::test]
    async fn test_view_seed_get_wallet_name_failure() {
        let (_, mut mock_mnemonic_provider, mut mock_name_provider, mut mock_password_scope) =
            setup_mocks();
        mock_password_scope
            .expect_unlock_password_change()
            .withf(|password, twofa| password == "correct_password" && twofa == "123456")
            .returning(|_, _| Ok(()));
        mock_mnemonic_provider
            .expect_get_wallet_mnemonic()
            .withf(|wallet_id| wallet_id == "wallet123")
            .returning(|_| Ok(WalletMnemonic::new_from_str("dummy_mnemonic")));
        mock_name_provider
            .expect_get_wallet_name()
            .withf(|wallet_id| wallet_id == "wallet123")
            .returning(|_| Err(WalletCryptoError::NoKeysFound.into()));

        let backup_mnemonic = BackupMnemonic {
            auth_provider: Arc::new(MockProtonAuthProvider::new()),
            wallet_mnemonic_provider: Arc::new(mock_mnemonic_provider),
            wallet_name_provider: Arc::new(mock_name_provider),
            unlock_password: Arc::new(mock_password_scope),
        };
        let result = backup_mnemonic
            .view_seed("wallet123".to_string(), "correct_password", "123456")
            .await;

        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap().to_string(),
            "Wallet provider error: Wallet crypto error: No user keys or address keys found error"
        );
    }
}

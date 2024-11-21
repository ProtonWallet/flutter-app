use andromeda_api::{
    proton_settings::{ProtonSettingsClientExt, SetTwoFaTOTPRequestBody, SetTwoFaTOTPResponseBody},
    proton_users::ProtonUserSettings,
};
use tracing::info;
use std::sync::Arc;

use super::{password_scope::PasswordScope, Result};
use crate::proton_wallet::provider::proton_auth::ProtonAuthProvider;

pub struct ProtonTowfa {
    pub(crate) auth_provider: Arc<dyn ProtonAuthProvider>,
    pub(crate) proton_settings_api: Arc<dyn ProtonSettingsClientExt>,
    ///feature dependency
    pub(crate) unlock_password: Arc<dyn PasswordScope>,
}

impl ProtonTowfa {
    pub async fn enable_twofa(
        &self,
        login_password: &str,
        twofa: &str,
        secret: &str,
    ) -> Result<SetTwoFaTOTPResponseBody> {
        self.unlock_password
            .unlock_password_change(login_password, twofa)
            .await?;

        let req = SetTwoFaTOTPRequestBody {
            TOTPConfirmation: twofa.to_string(),
            TOTPSharedSecret: secret.to_string(),
        };

        let response = self.proton_settings_api.enable_2fa_totp(req).await?;
        info!("enable_twofa response code: {}", response.Code);
        Ok(response)
    }

    pub async fn disable_twofa(
        &self,
        login_password: &str,
        twofa: &str,
    ) -> Result<ProtonUserSettings> {
        let client_proof = self
            .auth_provider
            .generate_client_proofs(login_password, twofa, None)
            .await?;

        let response = self
            .proton_settings_api
            .disable_2fa_totp(client_proof)
            .await?;
        info!("disable_twofa response Ok");
        Ok(response)
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use super::*;
    use crate::proton_wallet::{
        features::{
            error::FeaturesError, proton_settings::password_scope::mock::MockPasswordScope,
        },
        provider::{error::ProviderError, proton_auth::mock::MockProtonAuthProvider},
    };
    use andromeda_api::{
        error::Error,
        proton_settings::{SetTwoFaTOTPRequestBody, SetTwoFaTOTPResponseBody},
        proton_users::{ProtonSrpClientProofs, ProtonUserSettings},
        tests::proton_settings_mock::mock_utils::MockProtonSettingsClient,
    };
    use std::sync::Arc;

    fn setup_mocks() -> (
        MockProtonAuthProvider,
        MockProtonSettingsClient,
        MockPasswordScope,
    ) {
        (
            MockProtonAuthProvider::new(),
            MockProtonSettingsClient::new(),
            MockPasswordScope::new(),
        )
    }

    #[tokio::test]
    async fn test_enable_twofa_success() {
        let (mock_auth_provider, mut mock_settings_client, mut mock_password_scope) = setup_mocks();
        // Configure mocks for successful two-factor enabling
        mock_password_scope
            .expect_unlock_password_change()
            .withf(|password, twofa| password == "password" && twofa == "123456")
            .returning(|_, _| Ok(()));

        let req = SetTwoFaTOTPRequestBody {
            TOTPConfirmation: "123456".to_string(),
            TOTPSharedSecret: "secret".to_string(),
        };
        mock_settings_client
            .expect_enable_2fa_totp()
            .withf(move |r| r.TOTPConfirmation == req.TOTPConfirmation.clone())
            .returning(|_| {
                Ok(SetTwoFaTOTPResponseBody {
                    Code: 1000,
                    TwoFactorRecoveryCodes: vec!["a".to_owned(), "b".to_owned()],
                    UserSettings: ProtonUserSettings::default(),
                })
            });
        let towfa = ProtonTowfa {
            auth_provider: Arc::new(mock_auth_provider),
            proton_settings_api: Arc::new(mock_settings_client),
            unlock_password: Arc::new(mock_password_scope),
        };
        let response = towfa
            .enable_twofa("password", "123456", "secret")
            .await
            .unwrap();
        assert_eq!(response.Code, 1000);
    }

    #[tokio::test]
    async fn test_enable_twofa_unlock_failure() {
        let (_, mock_settings_client, mut mock_password_scope) = setup_mocks();
        // Simulate failure in unlocking password change
        mock_password_scope
            .expect_unlock_password_change()
            .returning(|_, _| Err(FeaturesError::InvalidSrpServerProofs.into()));
        let towfa = ProtonTowfa {
            auth_provider: Arc::new(MockProtonAuthProvider::new()),
            proton_settings_api: Arc::new(mock_settings_client),
            unlock_password: Arc::new(mock_password_scope),
        };
        let result = towfa.enable_twofa("password", "123456", "secret").await;
        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap().to_string(),
            "Invalid srp server proofs"
        );
    }

    #[tokio::test]
    async fn test_enable_twofa_unlock_failure_api() {
        let (_, mut mock_settings_client, mut mock_password_scope) = setup_mocks();
        mock_password_scope
            .expect_unlock_password_change()
            .withf(|password, twofa| password == "password" && twofa == "123456")
            .returning(|_, _| Ok(()));
        mock_settings_client
            .expect_enable_2fa_totp()
            .returning(|_| Err(Error::Http));
        let towfa = ProtonTowfa {
            auth_provider: Arc::new(MockProtonAuthProvider::new()),
            proton_settings_api: Arc::new(mock_settings_client),
            unlock_password: Arc::new(mock_password_scope),
        };
        let result = towfa.enable_twofa("password", "123456", "secret").await;
        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap().to_string(),
            "Andromeda api error: HTTP error"
        );
    }

    #[tokio::test]
    async fn test_disable_twofa_success() {
        let (mut mock_auth_provider, mut mock_settings_client, _) = setup_mocks();

        mock_auth_provider
            .expect_generate_client_proofs()
            .withf(|password, twofa, _| password == "password" && twofa == "123456")
            .returning(|_, _, _| {
                let mock_client_proofs = ProtonSrpClientProofs {
                    ClientEphemeral: "test_ephemeral".to_string(),
                    ClientProof: "test_proof".to_string(),
                    SRPSession: "test_session".to_string(),
                    TwoFactorCode: None,
                };
                Ok(mock_client_proofs)
            });
        mock_settings_client
            .expect_disable_2fa_totp()
            .withf(|proof| proof.ClientProof == "test_proof")
            .returning(|_| {
                let mock_user_settings = ProtonUserSettings {
                    News: 1000,
                    ..ProtonUserSettings::default()
                };
                Ok(mock_user_settings)
            });

        let towfa = ProtonTowfa {
            auth_provider: Arc::new(mock_auth_provider),
            proton_settings_api: Arc::new(mock_settings_client),
            unlock_password: Arc::new(MockPasswordScope::new()),
        };

        let response = towfa.disable_twofa("password", "123456").await.unwrap();
        assert_eq!(response.News, 1000);
    }

    #[tokio::test]
    async fn test_disable_twofa_proof_generation_failure() {
        let (mut mock_auth_provider, mock_settings_client, _) = setup_mocks();
        mock_auth_provider
            .expect_generate_client_proofs()
            .returning(|_, _, _| Err(ProviderError::NoWalletKeysFound));

        let towfa = ProtonTowfa {
            auth_provider: Arc::new(mock_auth_provider),
            proton_settings_api: Arc::new(mock_settings_client),
            unlock_password: Arc::new(MockPasswordScope::new()),
        };

        let result = towfa.disable_twofa("password", "123456").await;
        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap().to_string(),
            FeaturesError::Provider(ProviderError::NoWalletKeysFound).to_string()
        );
    }

    #[tokio::test]
    async fn test_disable_twofa_proof_generation_failure_network() {
        let (mut mock_auth_provider, mut mock_settings_client, _) = setup_mocks();
        mock_auth_provider
            .expect_generate_client_proofs()
            .withf(|password, twofa, _| password == "password" && twofa == "123456")
            .returning(|_, _, _| {
                let mock_client_proofs = ProtonSrpClientProofs {
                    ClientEphemeral: "test_ephemeral".to_string(),
                    ClientProof: "test_proof".to_string(),
                    SRPSession: "test_session".to_string(),
                    TwoFactorCode: None,
                };
                Ok(mock_client_proofs)
            });
        mock_settings_client
            .expect_disable_2fa_totp()
            .returning(|_| Err(Error::Http));
        let towfa = ProtonTowfa {
            auth_provider: Arc::new(mock_auth_provider),
            proton_settings_api: Arc::new(mock_settings_client),
            unlock_password: Arc::new(MockPasswordScope::new()),
        };

        let result = towfa.disable_twofa("password", "123456").await;
        assert!(result.is_err());
        assert_eq!(
            result.err().unwrap().to_string(),
            "Andromeda api error: HTTP error"
        );
    }
}

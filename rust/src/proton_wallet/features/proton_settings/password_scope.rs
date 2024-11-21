use async_trait::async_trait;
use std::sync::Arc;

use super::Result;
use crate::proton_wallet::{
    features::error::FeaturesError,
    provider::{proton_auth::ProtonAuthProvider, proton_user::ProtonUserDataProvider},
};

#[async_trait]
pub trait PasswordScope: Send + Sync {
    async fn unlock_password_change(&self, password: &str, twofa: &str) -> Result<()>;
}

#[derive(Clone)]
pub struct PasswordScopeImpl {
    pub(crate) auth_provider: Arc<dyn ProtonAuthProvider>,
    pub(crate) proton_users_provider: Arc<dyn ProtonUserDataProvider>,
}

impl PasswordScopeImpl {
    pub fn new(
        auth_provider: Arc<dyn ProtonAuthProvider>,
        proton_users_provider: Arc<dyn ProtonUserDataProvider>,
    ) -> Self {
        PasswordScopeImpl {
            auth_provider,
            proton_users_provider,
        }
    }
}

#[async_trait]
impl PasswordScope for PasswordScopeImpl {
    async fn unlock_password_change(&self, login_password: &str, twofa: &str) -> Result<()> {
        let auth_info = self.auth_provider.auth_info().await?;
        // srp proof, will need server proof to verify
        let srp_proof = self
            .auth_provider
            .generate_srp_proofs(login_password, Some(auth_info.clone()))
            .await?;
        // build client proofs
        let client_proofs = self
            .auth_provider
            .build_client_proofs(twofa, &auth_info, &srp_proof)?;

        // Unlock password change with the server
        let server_proofs = self
            .proton_users_provider
            .unlock_password_change(client_proofs)
            .await?;

        // Check if the server proofs are valid
        let is_valid = srp_proof.expected_server_proof == server_proofs;
        tracing::info!("Password server proofs valid: {}", is_valid);
        if !is_valid {
            return Err(FeaturesError::InvalidSrpServerProofs);
        }
        Ok(())
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
pub mod mock {
    use super::*;
    use async_trait::async_trait;
    use mockall::mock;
    mock! {
        pub PasswordScope {}
        #[async_trait]
        impl PasswordScope for PasswordScope {
            async fn unlock_password_change(&self, password: &str, twofa: &str) -> Result<()>;
        }
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use super::*;
    use crate::{
        mocks::auth::tests::mock_auth_info_response,
        proton_wallet::provider::{
            proton_auth::mock::MockProtonAuthProvider,
            proton_user::mock::MockProtonUserDataProvider,
        },
    };
    use andromeda_api::proton_users::ProtonSrpClientProofs;
    use proton_srp::SRPProofB64;
    use std::sync::Arc;

    #[tokio::test]
    async fn test_unlock_password_change_success() {
        let mut mock_auth_provider = MockProtonAuthProvider::new();
        let mut mock_user_provider = MockProtonUserDataProvider::new();
        let auth_info = mock_auth_info_response();

        mock_auth_provider
            .expect_auth_info()
            .times(1)
            .returning(move || Ok(auth_info.clone()));
        let srp_proof = SRPProofB64 {
            client_ephemeral: "client_ephemeral".to_string(),
            client_proof: "client_proof".to_string(),
            expected_server_proof: "expected_server_proof".to_string(),
        };
        mock_auth_provider
            .expect_generate_srp_proofs()
            .withf(|password, _| password == "password")
            .times(1)
            .returning(move |_, _| Ok(srp_proof.clone()));
        let srp_proof = SRPProofB64 {
            client_ephemeral: "client_ephemeral".to_string(),
            client_proof: "client_proof".to_string(),
            expected_server_proof: "expected_server_proof".to_string(),
        };
        let client_proofs = ProtonSrpClientProofs {
            ClientEphemeral: srp_proof.client_ephemeral.clone(),
            ClientProof: srp_proof.client_proof.clone(),
            SRPSession: "test_session".to_string(),
            TwoFactorCode: Some("123456".to_string()),
        };
        mock_auth_provider
            .expect_build_client_proofs()
            .times(1)
            .returning(move |_, _, _| Ok(client_proofs.clone()));

        mock_user_provider
            .expect_unlock_password_change()
            .withf(|proofs| proofs.ClientProof == "client_proof")
            .times(1)
            .returning(|_| Ok("expected_server_proof".to_string()));

        let scope =
            PasswordScopeImpl::new(Arc::new(mock_auth_provider), Arc::new(mock_user_provider));
        let result = scope.unlock_password_change("password", "123456").await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_unlock_password_change_invalid_server_proof() {
        let mut mock_auth_provider = MockProtonAuthProvider::new();
        let mut mock_user_provider = MockProtonUserDataProvider::new();
        let auth_info = mock_auth_info_response();

        let srp_proof = SRPProofB64 {
            client_ephemeral: "client_ephemeral".to_string(),
            client_proof: "client_proof".to_string(),
            expected_server_proof: "expected_server_proof".to_string(),
        };
        let client_proofs = ProtonSrpClientProofs {
            ClientEphemeral: srp_proof.client_ephemeral.clone(),
            ClientProof: srp_proof.client_proof.clone(),
            SRPSession: "test_session".to_string(),
            TwoFactorCode: Some("123456".to_string()),
        };

        mock_auth_provider
            .expect_auth_info()
            .times(1)
            .returning(move || Ok(auth_info.clone()));
        mock_auth_provider
            .expect_generate_srp_proofs()
            .withf(|password, _| password == "password")
            .times(1)
            .returning(move |_, _| Ok(srp_proof.clone()));
        mock_auth_provider
            .expect_build_client_proofs()
            .times(1)
            .returning(move |_, _, _| Ok(client_proofs.clone()));
        mock_user_provider
            .expect_unlock_password_change()
            .withf(|proofs| proofs.ClientProof == "client_proof")
            .times(1)
            .returning(|_| Ok("invalid_server_proof".to_string()));

        let scope =
            PasswordScopeImpl::new(Arc::new(mock_auth_provider), Arc::new(mock_user_provider));
        let result = scope.unlock_password_change("password", "123456").await;
        assert!(matches!(result, Err(FeaturesError::InvalidSrpServerProofs)));
    }
}

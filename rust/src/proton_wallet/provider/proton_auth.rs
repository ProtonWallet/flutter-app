use andromeda_api::proton_users::{
    GetAuthInfoRequest, GetAuthInfoResponseBody, ProtonSrpClientProofs, ProtonUsersClientExt,
};
use async_trait::async_trait;
use proton_srp::SRPProofB64;
use std::sync::Arc;

use super::{proton_auth_model::AuthVerifier, Result};
use crate::proton_wallet::crypto::srp::SrpClient;

/// Trait defining the behavior of an authentication provider.
#[async_trait]
pub trait ProtonAuthProvider: Send + Sync {
    /// Fetches authentication information required for login.
    async fn auth_info(&self) -> Result<GetAuthInfoResponseBody>;

    /// Generates client proofs needed for Proton authentication using the provided login credentials.
    ///
    /// # Parameters
    /// - `login_password`: The user's login password.
    /// - `twofa`: Optional two-factor authentication code, if enabled.
    /// - `auth_info`: Optional authentication information. If not provided, it will be fetched automatically.
    ///
    /// # Returns
    /// - A `ProtonSrpClientProofs` object containing ephemeral keys, proof, session data, and optional 2FA code.
    async fn generate_srp_proofs(
        &self,
        login_password: &str,
        auth_info: Option<GetAuthInfoResponseBody>,
    ) -> Result<SRPProofB64>;

    /// Generates client proofs needed for Proton authentication using the provided login credentials.
    ///
    /// # Parameters
    /// - `login_password`: The user's login password.
    /// - `twofa`: Optional two-factor authentication code, if enabled.
    /// - `auth_info`: Optional authentication information. If not provided, it will be fetched automatically.
    ///
    /// # Returns
    /// - A `ProtonSrpClientProofs` object containing ephemeral keys, proof, session data, and optional 2FA code.
    async fn generate_client_proofs(
        &self,
        login_password: &str,
        twofa: &str,
        auth_info: Option<GetAuthInfoResponseBody>,
    ) -> Result<ProtonSrpClientProofs>;

    fn build_client_proofs(
        &self,
        twofa: &str,
        auth_info: &GetAuthInfoResponseBody,
        srp_proof: &SRPProofB64,
    ) -> Result<ProtonSrpClientProofs>;

    async fn generate_auth_module(&self, password: &str) -> Result<AuthVerifier>;
}

/// Implementation of the ProtonAuthProvider trait.
#[derive(Clone)]
pub struct ProtonAuthProviderImpl {
    pub(crate) proton_user_client: Arc<dyn ProtonUsersClientExt + Send + Sync>,
}

impl ProtonAuthProviderImpl {
    /// Creates a new instance of the `ProtonAuthProviderImpl`.
    pub fn new(proton_user_client: Arc<dyn ProtonUsersClientExt + Send + Sync>) -> Self {
        ProtonAuthProviderImpl { proton_user_client }
    }
}

#[async_trait]
impl ProtonAuthProvider for ProtonAuthProviderImpl {
    /// Fetches authentication information from the Proton server.
    async fn auth_info(&self) -> Result<GetAuthInfoResponseBody> {
        // Request authentication info from the Proton API with the intent 'Proton'.
        self.proton_user_client
            .get_auth_info(GetAuthInfoRequest {
                Intent: "Proton".to_string(),
            })
            .await
            .map_err(Into::into) // Convert API error to the appropriate result type
    }

    /// Generates the client proofs for Proton authentication.
    async fn generate_srp_proofs(
        &self,
        login_password: &str,
        auth_info: Option<GetAuthInfoResponseBody>,
    ) -> Result<SRPProofB64> {
        // If auth_info is not provided, fetch it automatically.
        let auth_info = match auth_info {
            Some(info) => info,
            None => self.auth_info().await?,
        };

        // Generate the client proofs using the SRP provider
        let proofs = SrpClient::generate_proofs(
            login_password,
            auth_info.Version,
            &auth_info.Salt,
            &auth_info.Modulus,
            &auth_info.ServerEphemeral,
        )?;

        Ok(SRPProofB64 {
            client_ephemeral: proofs.client_ephemeral,
            client_proof: proofs.client_proof,
            expected_server_proof: proofs.expected_server_proof,
        })
    }

    /// Generates the client proofs for Proton authentication.
    async fn generate_client_proofs(
        &self,
        login_password: &str,
        twofa: &str,
        auth_info: Option<GetAuthInfoResponseBody>,
    ) -> Result<ProtonSrpClientProofs> {
        // If auth_info is not provided, fetch it automatically.
        let auth_info = match auth_info {
            Some(info) => info,
            None => self.auth_info().await?,
        };

        let srp_proof = self
            .generate_srp_proofs(login_password, Some(auth_info.clone()))
            .await?;

        // Check if 2FA is enabled and add the two-factor code if needed
        Ok(self.build_client_proofs(twofa, &auth_info, &srp_proof)?)
    }

    // in some case business logic need to verify server proofs in ohter api response. this build client proof manually
    fn build_client_proofs(
        &self,
        twofa: &str,
        auth_info: &GetAuthInfoResponseBody,
        srp_proof: &SRPProofB64,
    ) -> Result<ProtonSrpClientProofs> {
        // Check if 2FA is enabled and add the two-factor code if needed
        let proofs = if auth_info.two_fa.Enabled != 0 {
            ProtonSrpClientProofs {
                ClientEphemeral: srp_proof.client_ephemeral.clone(),
                ClientProof: srp_proof.client_proof.clone(),
                SRPSession: auth_info.SRPSession.clone(),
                TwoFactorCode: Some(twofa.to_string()),
            }
        } else {
            ProtonSrpClientProofs {
                ClientEphemeral: srp_proof.client_ephemeral.clone(),
                ClientProof: srp_proof.client_proof.clone(),
                SRPSession: auth_info.SRPSession.clone(),
                TwoFactorCode: None,
            }
        };
        Ok(proofs)
    }

    async fn generate_auth_module(&self, password: &str) -> Result<AuthVerifier> {
        let server_module = self.proton_user_client.get_auth_modulus().await?;

        // Generate a verifier with the recovery password and server modulus
        let verifier = SrpClient::generate_verifier(password, &server_module.Modulus)?;

        // Prepare the mnemonic authentication object
        Ok(AuthVerifier {
            modulus_id: server_module.ModulusID,
            salt: verifier.salt,
            version: verifier.version as u32,
            verifier: verifier.verifier,
        })
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
pub mod mock {
    use super::*;
    use async_trait::async_trait;
    use mockall::mock;
    mock! {
        pub ProtonAuthProvider {}
        #[async_trait]
        impl ProtonAuthProvider for ProtonAuthProvider {
            async fn auth_info(&self) -> Result<GetAuthInfoResponseBody>;
            async fn generate_srp_proofs(&self, login_password: &str, auth_info: Option<GetAuthInfoResponseBody>) -> Result<SRPProofB64>;
            async fn generate_client_proofs(&self, login_password: &str, twofa: &str, auth_info: Option<GetAuthInfoResponseBody>) -> Result<ProtonSrpClientProofs>;
            async fn generate_auth_module(&self, password: &str) -> Result<AuthVerifier>;
            fn build_client_proofs(&self, twofa: &str, auth_info: &GetAuthInfoResponseBody, srp_proof: &SRPProofB64) -> Result<ProtonSrpClientProofs>;
        }
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
mod tests {
    use super::*;
    use crate::mocks::*;
    use andromeda_api::tests::proton_users_mock::mock_utils::MockProtonUsersClient;
    use auth::tests::{
        mock_auth_info_response, TEST_MODULUS_CLEAR_SIGN, TEST_SALT, TEST_SERVER_EPHEMERAL,
    };
    use std::sync::Arc;

    #[tokio::test]
    async fn test_auth_info() {
        let mut mock_client = MockProtonUsersClient::new();
        mock_client
            .expect_get_auth_info()
            .returning(|_| Ok(mock_auth_info_response()));

        let auth_provider = ProtonAuthProviderImpl::new(Arc::new(mock_client));
        let auth_info = auth_provider.auth_info().await.unwrap();
        assert_eq!(auth_info.Version, 4);
        assert_eq!(auth_info.Salt, TEST_SALT);
        assert_eq!(auth_info.Modulus, TEST_MODULUS_CLEAR_SIGN);
        assert_eq!(auth_info.ServerEphemeral, TEST_SERVER_EPHEMERAL);

        let proofs = auth_provider
            .generate_srp_proofs("password", None)
            .await
            .unwrap();

        assert!(!proofs.client_ephemeral.is_empty());
        assert!(!proofs.client_proof.is_empty());
        assert!(!proofs.expected_server_proof.is_empty());

        let client_proofs = auth_provider
            .generate_client_proofs("password", "123456", None)
            .await
            .unwrap();

        assert!(!client_proofs.ClientEphemeral.is_empty());
        assert!(!client_proofs.ClientProof.is_empty());
        assert_eq!(client_proofs.SRPSession, "test_session");
        assert_eq!(client_proofs.TwoFactorCode.unwrap(), "123456");
    }

    #[tokio::test]
    async fn test_build_client_proofs_without_2fa() {
        let mut mock_client = MockProtonUsersClient::new();
        mock_client.expect_get_auth_info().returning(|_| {
            let mut info = mock_auth_info_response();
            info.two_fa.Enabled = 0;
            Ok(info)
        });
        let auth_provider = ProtonAuthProviderImpl::new(Arc::new(mock_client));
        let auth_info = auth_provider.auth_info().await.unwrap();
        let proofs = auth_provider
            .generate_srp_proofs("password", None)
            .await
            .unwrap();
        let client_proofs = auth_provider
            .build_client_proofs("123456", &auth_info, &proofs)
            .unwrap();
        assert!(!client_proofs.ClientEphemeral.is_empty());
        assert!(!client_proofs.ClientProof.is_empty());
        assert_eq!(client_proofs.SRPSession, "test_session");
        assert!(client_proofs.TwoFactorCode.is_none());
    }
}

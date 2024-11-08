use andromeda_api::{
    core::ApiClient,
    proton_users::{
        GetAuthInfoRequest, GetAuthInfoResponseBody, GetAuthModulusResponse, ProtonSrpClientProofs,
        ProtonUser, ProtonUserSettings, ProtonUsersClientExt,
    },
    ProtonUsersClient as InnerProtonUsersClient,
};

use super::proton_api_service::ProtonAPIService;
use crate::BridgeError;

pub struct ProtonUsersClient {
    pub(crate) inner: InnerProtonUsersClient,
}

impl ProtonUsersClient {
    pub fn new(client: &ProtonAPIService) -> ProtonUsersClient {
        ProtonUsersClient {
            inner: InnerProtonUsersClient::new(client.inner.clone()),
        }
    }

    pub async fn get_user_info(&self) -> Result<ProtonUser, BridgeError> {
        Ok(self.inner.get_user_info().await?)
    }

    pub async fn get_user_settings(&self) -> Result<ProtonUserSettings, BridgeError> {
        Ok(self.inner.get_user_settings().await?)
    }

    pub async fn get_auth_info(
        &self,
        intent: String,
    ) -> Result<GetAuthInfoResponseBody, BridgeError> {
        Ok(self
            .inner
            .get_auth_info(GetAuthInfoRequest { Intent: intent })
            .await?)
    }

    pub async fn get_auth_module(&self) -> Result<GetAuthModulusResponse, BridgeError> {
        Ok(self.inner.get_auth_modulus().await?)
    }

    pub async fn unlock_password_change(
        &self,
        proofs: ProtonSrpClientProofs,
    ) -> Result<String, BridgeError> {
        Ok(self.inner.unlock_password_change(proofs).await?)
    }

    pub async fn lock_sensitive_settings(&self) -> Result<u32, BridgeError> {
        Ok(self.inner.lock_sensitive_settings().await?)
    }

    pub async fn unlock_sensitive_settings(
        &self,
        proofs: ProtonSrpClientProofs,
    ) -> Result<String, BridgeError> {
        Ok(self.inner.unlock_sensitive_settings(proofs).await?)
    }
}

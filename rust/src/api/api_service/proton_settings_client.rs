use crate::BridgeError;

use super::proton_api_service::ProtonAPIService;
pub use andromeda_api::proton_settings::ProtonSettingsClient as InnerProtonSettingsClient;
use andromeda_api::{
    core::ApiClient,
    proton_settings::{ApiMnemonicUserKey, UpdateMnemonicSettingsRequestBody},
    proton_users::ProtonSrpClientProofs,
};

pub struct ProtonSettingsClient {
    pub(crate) inner: InnerProtonSettingsClient,
}

impl ProtonSettingsClient {
    pub fn new(client: &ProtonAPIService) -> Self {
        ProtonSettingsClient {
            inner: InnerProtonSettingsClient::new(client.inner.clone()),
        }
    }

    pub async fn disable_mnemonic_settings(
        &self,
        proofs: ProtonSrpClientProofs,
    ) -> Result<String, BridgeError> {
        Ok(self.inner.disable_mnemonic_settings(proofs).await?)
    }

    pub async fn set_mnemonic_settings(
        &self,
        req: UpdateMnemonicSettingsRequestBody,
    ) -> Result<u32, BridgeError> {
        Ok(self.inner.set_mnemonic_settings(req).await?)
    }

    pub async fn reactive_mnemonic_settings(
        &self,
        req: UpdateMnemonicSettingsRequestBody,
    ) -> Result<u32, BridgeError> {
        Ok(self.inner.reactive_mnemonic_settings(req).await?)
    }

    pub async fn get_mnemonic_settings(&self) -> Result<Vec<ApiMnemonicUserKey>, BridgeError> {
        Ok(self.inner.get_mnemonic_settings().await?)
    }
}

use crate::BridgeError;

use super::proton_api_service::ProtonAPIService;
pub use andromeda_api::proton_settings::ProtonSettingsClient as InnerProtonSettingsClient;
use andromeda_api::{
    core::ApiClient,
    proton_settings::{
        ApiMnemonicUserKey, ProtonSettingsClientExt, SetTwoFaTOTPRequestBody,
        SetTwoFaTOTPResponseBody, UpdateMnemonicSettingsRequestBody,
    },
    proton_users::{ProtonSrpClientProofs, ProtonUserSettings},
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

    pub async fn enable_2fa_totp(
        &self,
        req: SetTwoFaTOTPRequestBody,
    ) -> Result<SetTwoFaTOTPResponseBody, BridgeError> {
        Ok(self.inner.enable_2fa_totp(req).await?)
    }

    pub async fn disable_2fa_totp(
        &self,
        req: ProtonSrpClientProofs,
    ) -> Result<ProtonUserSettings, BridgeError> {
        Ok(self.inner.disable_2fa_totp(req).await?)
    }
}

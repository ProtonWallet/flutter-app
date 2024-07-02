use super::proton_api_service::ProtonAPIService;
use andromeda_api::core::ApiClient;
pub use andromeda_api::proton_settings::ProtonSettingsClient as InnerProtonSettingsClient;

pub struct ProtonSettingsClient {
    pub inner: InnerProtonSettingsClient,
}

impl ProtonSettingsClient {
    pub fn new(client: &ProtonAPIService) -> Self {
        ProtonSettingsClient {
            inner: InnerProtonSettingsClient::new(client.inner.clone()),
        }
    }

    // pub async fn get_mnemonic_settings(&self) -> Result<Vec<ApiMnemonicUserKey>, Error> {
    //     let request = self.get("settings/mnemonic");
    //     let response = self.api_client.send(request).await?;
    //     let parsed = response.parse_response::<GetMnemonicSettingsResponseBody>()?;
    //     Ok(parsed.MnemonicUserKeys)
    // }

    // pub async fn set_mnemonic_settings(&self, req: UpdateMnemonicSettingsRequestBody) -> Result<String, Error> {
    //     let request = self.put("settings/mnemonic").body_json(req)?;

    //     let response = self.api_client.send(request).await?;
    //     let parsed = response.parse_response::<UpdateMnemonicSettingsResponseBody>()?;
    //     Ok(parsed.ServerProof)
    // }

    // pub async fn reactive_mnemonic_settings(&self, req: UpdateMnemonicSettingsRequestBody) -> Result<String, Error> {
    //     let request = self.put("settings/mnemonic/reactive").body_json(req)?;

    //     let response = self.api_client.send(request).await?;
    //     let parsed = response.parse_response::<UpdateMnemonicSettingsResponseBody>()?;
    //     Ok(parsed.ServerProof)
    // }

    // pub async fn disable_mnemonic_settings(&self) -> Result<String, BridgeError> {
    //     self.inner.disable_mnemonic_settings().await?
    // }
}

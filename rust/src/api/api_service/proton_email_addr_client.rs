use std::sync::Arc;

use andromeda_api::core::ApiClient;

use crate::{
    BridgeError,
    proton_address::{AllKeyAddressKey, ProtonAddress},
};

use super::proton_api_service::ProtonAPIService;

pub struct ProtonEmailAddressClient {
    pub inner: Arc<andromeda_api::proton_email_address::ProtonEmailAddressClient>,
}

impl ProtonEmailAddressClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(
                andromeda_api::proton_email_address::ProtonEmailAddressClient::new(
                    service.inner.clone(),
                ),
            ),
        }
    }

    pub async fn get_all_public_keys(
        &self,
        email: String,
        internal_only: u8,
    ) -> Result<Vec<AllKeyAddressKey>, BridgeError> {
        let result = self
            .inner
            .get_all_public_keys(email, Some(internal_only))
            .await;
        match result {
            Ok(response) => Ok(response.into_iter().map(|v| v.into()).collect()),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn get_proton_address(&self) -> Result<Vec<ProtonAddress>, BridgeError> {
        let result = self.inner.get_proton_email_addresses().await;
        match result {
            Ok(response) => Ok(response.into_iter().map(|x| x.into()).collect()),
            Err(err) => Err(err.into()),
        }
    }
}

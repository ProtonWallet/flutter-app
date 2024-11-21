use andromeda_api::{core::ApiClient, unleash::UnleashResponse};
use std::sync::Arc;

use super::proton_api_service::ProtonAPIService;
use crate::BridgeError;

pub struct FrbUnleashClient {
    pub(crate) inner: Arc<andromeda_api::unleash::UnleashClient>,
}

impl FrbUnleashClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(andromeda_api::unleash::UnleashClient::new(
                service.inner.clone(),
            )),
        }
    }

    pub async fn fetch_toggles(&self) -> Result<UnleashResponse, BridgeError> {
        Ok(self.inner.fetch_toggles().await?)
    }
}

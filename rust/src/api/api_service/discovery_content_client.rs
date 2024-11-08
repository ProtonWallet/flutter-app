use andromeda_api::{core::ApiClient, discovery_content::Content};
use std::sync::Arc;

use super::proton_api_service::ProtonAPIService;
use crate::BridgeError;

pub struct DiscoveryContentClient {
    pub(crate) inner: Arc<andromeda_api::discovery_content::DiscoverContentClient>,
}

impl DiscoveryContentClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(
                andromeda_api::discovery_content::DiscoverContentClient::new(service.inner.clone()),
            ),
        }
    }

    pub async fn get_discovery_contents(&self) -> Result<Vec<Content>, BridgeError> {
        Ok(self.inner.get_discovery_contents().await?)
    }
}

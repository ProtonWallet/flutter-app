use andromeda_api::core::ApiClient;
use std::sync::Arc;

use super::proton_api_service::ProtonAPIService;
use crate::BridgeError;

pub struct BlockClient {
    pub(crate) inner: Arc<andromeda_api::block::BlockClient>,
}

impl BlockClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(andromeda_api::block::BlockClient::new(
                service.inner.clone(),
            )),
        }
    }

    pub async fn get_tip_height(&self) -> Result<u32, BridgeError> {
        Ok(self.inner.get_tip_height().await?)
    }
}

use std::sync::Arc;
use andromeda_api::core::ApiClient;

use super::proton_api_service::ProtonAPIService;
use crate::{wallet::EmailIntegrationBitcoinAddress, BridgeError};

pub struct EmailIntegrationClient {
    pub(crate) inner: Arc<andromeda_api::email_integration::EmailIntegrationClient>,
}

impl EmailIntegrationClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(
                andromeda_api::email_integration::EmailIntegrationClient::new(
                    service.inner.clone(),
                ),
            ),
        }
    }

    pub async fn lookup_bitcoin_address(
        &self,
        email: String,
    ) -> Result<EmailIntegrationBitcoinAddress, BridgeError> {
        let result = self.inner.lookup_bitcoin_address(email).await?;
        Ok(result.into())
    }
}

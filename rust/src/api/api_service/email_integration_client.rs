use std::sync::Arc;

use crate::{errors::ApiError, wallet::EmailIntegrationBitcoinAddress};

use super::proton_api_service::ProtonAPIService;

pub struct EmailIntegrationClient {
    pub inner: Arc<andromeda_api::email_integration::EmailIntegrationClient>,
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
    ) -> Result<EmailIntegrationBitcoinAddress, ApiError> {
        let result = self.inner.lookup_bitcoin_address(email).await;
        match result {
            Ok(response) => Ok(response.into()),
            Err(err) => Err(err.into()),
        }
    }
}

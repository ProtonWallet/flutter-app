use super::proton_api_service::ProtonAPIService;
use crate::errors::BridgeError;
use andromeda_api::{contacts::ApiContactEmails, core::ApiClient};
use std::sync::Arc;

pub struct ContactsClient {
    pub inner: Arc<andromeda_api::contacts::ContactsClient>,
}

impl ContactsClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(andromeda_api::contacts::ContactsClient::new(
                service.inner.clone(),
            )),
        }
    }

    pub async fn get_contacts(&self) -> Result<Vec<ApiContactEmails>, BridgeError> {
        let result = self.inner.get_contacts(Some(1000), Some(0)).await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }
}

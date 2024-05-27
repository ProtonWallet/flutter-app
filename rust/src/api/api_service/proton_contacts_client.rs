use crate::{contacts::ProtonContactEmails, errors::ApiError};

use super::proton_api_service::ProtonAPIService;
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

    pub async fn get_contacts(&self) -> Result<Vec<ProtonContactEmails>, ApiError> {
        let result = self.inner.get_contacts(Some(1000), Some(0)).await;
        match result {
            Ok(response) => Ok(response.into_iter().map(|x| x.into()).collect()),
            Err(err) => Err(err.into()),
        }
    }
}

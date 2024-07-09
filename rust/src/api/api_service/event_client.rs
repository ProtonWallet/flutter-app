use std::sync::Arc;

use andromeda_api::core::ApiClient;

use crate::{event_routes::ProtonEvent, BridgeError};

use super::proton_api_service::ProtonAPIService;

pub struct EventClient {
    pub(crate) inner: Arc<andromeda_api::event::EventClient>,
}

impl EventClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(andromeda_api::event::EventClient::new(
                service.inner.clone(),
            )),
        }
    }

    pub async fn get_latest_event_id(&self) -> Result<String, BridgeError> {
        Ok(self.inner.get_latest_event_id().await?)
    }

    pub async fn collect_events(
        &self,
        latest_event_id: String,
    ) -> Result<Vec<ProtonEvent>, BridgeError> {
        let result = self.inner.collect_events(latest_event_id).await;
        match result {
            Ok(response) => Ok(response.into_iter().map(|x| x.into()).collect()),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn is_valid_token(&self) -> Result<bool, BridgeError> {
        let result = self.get_latest_event_id().await;
        match result {
            Ok(_) => Ok(true),
            Err(_) => Ok(false),
        }
    }
}

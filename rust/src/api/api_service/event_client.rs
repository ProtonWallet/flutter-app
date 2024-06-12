use std::sync::Arc;

use andromeda_api::core::ApiClient;

use crate::{errors::ApiError, event_routes::ProtonEvent};

use super::proton_api_service::ProtonAPIService;

pub struct EventClient {
    pub inner: Arc<andromeda_api::event::EventClient>,
}

impl EventClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(andromeda_api::event::EventClient::new(
                service.inner.clone(),
            )),
        }
    }

    pub async fn get_latest_event_id(&self) -> Result<String, ApiError> {
        let result = self.inner.get_latest_event_id().await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn collect_events(
        &self,
        latest_event_id: String,
    ) -> Result<Vec<ProtonEvent>, ApiError> {
        let result = self.inner.collect_events(latest_event_id).await;
        match result {
            Ok(response) => Ok(response.into_iter().map(|x| x.into()).collect()),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn is_valid_token(&self) -> Result<bool, ApiError> {
        let result = self.get_latest_event_id().await;
        match result {
            Ok(_) => Ok(true),
            Err(_) => Ok(false),
        }
    }
}

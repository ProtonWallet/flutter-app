use super::proton_api_service::ProtonAPIService;
use crate::errors::BridgeError;
use andromeda_api::core::ApiClient;
use std::sync::Arc;

pub struct InviteClient {
    pub inner: Arc<andromeda_api::invite::InviteClient>,
}

impl InviteClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(andromeda_api::invite::InviteClient::new(
                service.inner.clone(),
            )),
        }
    }

    pub async fn send_newcomer_invite(&self, invitee_email: String) -> Result<u16, BridgeError> {
        let result = self.inner.send_newcomer_invite(invitee_email).await;
        match result {
            Ok(response) => Ok(response.Code),
            Err(err) => Err(err.into()),
        }
    }

    pub async fn send_email_integration_invite(
        &self,
        invitee_email: String,
    ) -> Result<u16, BridgeError> {
        let result = self
            .inner
            .send_email_integration_invite(invitee_email)
            .await;
        match result {
            Ok(response) => Ok(response.Code),
            Err(err) => Err(err.into()),
        }
    }
}

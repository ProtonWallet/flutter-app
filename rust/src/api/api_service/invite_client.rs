use std::{collections::HashMap, sync::Arc};

pub use andromeda_api::core::ApiClient;

use crate::BridgeError;

use super::proton_api_service::ProtonAPIService;

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

    pub async fn send_email_integration_invite(
        &self,
        invitee_email: String,
    ) -> Result<(), BridgeError> {
        Ok(self
            .inner
            .send_email_integration_invite(invitee_email)
            .await?)
    }

    pub async fn send_newcomer_invite(&self, invitee_email: String) -> Result<(), BridgeError> {
        Ok(self.inner.send_newcomer_invite(invitee_email).await?)
    }

    pub async fn check_invite_status(&self, invitee_email: String) -> Result<(), BridgeError> {
        Ok(self.inner.check_invite_status(invitee_email).await?)
    }
}

use std::sync::Arc;

pub use andromeda_api::core::ApiClient;
use andromeda_api::invite::{InviteNotificationType, RemainingMonthlyInvitations};

use crate::BridgeError;

use super::proton_api_service::ProtonAPIService;

pub struct InviteClient {
    pub(crate) inner: Arc<andromeda_api::invite::InviteClient>,
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
        inviter_address_id: String,
    ) -> Result<(), BridgeError> {
        Ok(self
            .inner
            .send_email_integration_invite(invitee_email, inviter_address_id)
            .await?)
    }

    pub async fn send_newcomer_invite(
        &self,
        invitee_email: String,
        inviter_address_id: String,
    ) -> Result<(), BridgeError> {
        Ok(self
            .inner
            .send_newcomer_invite(invitee_email, inviter_address_id)
            .await?)
    }

    pub async fn check_invite_status(
        &self,
        invitee_email: String,
        invite_notification_type: InviteNotificationType,
        inviter_address_id: String,
    ) -> Result<u8, BridgeError> {
        Ok(self
            .inner
            .check_invite_status(invitee_email, invite_notification_type, inviter_address_id)
            .await?)
    }

    pub async fn get_remaining_monthly_invitation(
        &self,
    ) -> Result<RemainingMonthlyInvitations, BridgeError> {
        Ok(self.inner.get_remaining_monthly_invitation().await?)
    }
}

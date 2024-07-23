pub use andromeda_api::invite::{InviteNotificationType, RemainingMonthlyInvitations};
use flutter_rust_bridge::frb;

#[frb(mirror(InviteNotificationType))]
pub enum _InviteNotificationType {
    Newcomer,
    EmailIntegration,
    Unsupported,
}

#[frb(mirror(RemainingMonthlyInvitations))]
pub struct _RemainingMonthlyInvitations {
    pub Used: u8,
    pub Available: u8,
}

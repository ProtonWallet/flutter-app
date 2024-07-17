pub use andromeda_api::invite::InviteNotificationType;
use flutter_rust_bridge::frb;

#[frb(mirror(InviteNotificationType))]
pub enum _InviteNotificationType {
    Newcomer,
    EmailIntegration,
    Unsupported,
}

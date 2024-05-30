pub use andromeda_api::ChildSession;
use flutter_rust_bridge::frb;

pub struct AuthCredential {
    // Session unique ID
    pub session_id: String,
    // user id
    pub user_id: String,
    pub access_token: String,
    pub refresh_token: String,
    pub event_id: String,
    pub user_mail: String,
    pub user_name: String,
    pub display_name: String,
    pub scops: Vec<String>,
    pub user_key_id: String,
    pub user_private_key: String,
    pub user_passphrase: String,
}

#[frb(mirror(ChildSession))]
struct _ChildSession {
    pub session_id: String,
    pub access_token: String,
    pub refresh_token: String,
    pub scopes: Vec<String>,
}

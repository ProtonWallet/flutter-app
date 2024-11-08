use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct NativeSessionModel {
    pub user_id: String,
    pub session_id: String,
    pub user_name: String,
    pub passphrase: String,
    pub access_token: String,
    pub refresh_token: String,
    pub scopes: Vec<String>,
}

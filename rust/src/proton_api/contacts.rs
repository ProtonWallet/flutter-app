pub use andromeda_api::contacts::ApiContactEmails;
use flutter_rust_bridge::frb;

#[frb(mirror(ApiContactEmails))]
#[allow(non_snake_case)]
pub struct _ApiContactEmails {
    pub ID: String,
    pub Name: String,
    pub Email: String,
    pub CanonicalEmail: String,
    pub IsProton: u32,
}

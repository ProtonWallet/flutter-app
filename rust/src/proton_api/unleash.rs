pub use andromeda_api::unleash::UnleashResponse;
use flutter_rust_bridge::frb;

#[frb(mirror(UnleashResponse))]
pub struct _UnleashResponse {
    pub status_code: u16,
    pub body: Vec<u8>,
}

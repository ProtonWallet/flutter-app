use crate::{
    auth_store::{set_session_update_delegate, DartFnFuture},
    errors::ApiError,
};
use flutter_rust_bridge::frb;

pub struct ProtonWalletAuthStore {}

impl ProtonWalletAuthStore {
    #[frb(sync)]
    pub fn set_dart_callback(
        callback: impl Fn(String) -> DartFnFuture<String> + Send + Sync + 'static,
    ) -> Result<(), ApiError> {
        set_session_update_delegate(callback)
    }
}

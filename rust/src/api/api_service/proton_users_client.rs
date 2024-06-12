use std::sync::Arc;

use super::proton_api_service::ProtonAPIService;
use andromeda_api::core::ApiClient;
pub use andromeda_api::ProtonUsersClient as InnerProtonUsersClient;

pub struct ProtonUsersClient {
    pub inner: InnerProtonUsersClient,
}

impl ProtonUsersClient {
    pub fn new(client: Arc<ProtonAPIService>) -> ProtonUsersClient {
        ProtonUsersClient {
            inner: InnerProtonUsersClient::new(client.inner.clone()),
        }
    }
}

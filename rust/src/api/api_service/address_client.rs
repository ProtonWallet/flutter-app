use std::sync::Arc;

pub use andromeda_api::address::{AddressBalance, ApiTx};

use crate::errors::ApiError;

use super::proton_api_service::ProtonAPIService;

pub struct AddressClient {
    pub inner: Arc<andromeda_api::address::AddressClient>,
}

impl AddressClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(andromeda_api::address::AddressClient::new(
                service.inner.clone(),
            )),
        }
    }

    /// Get recent block summaries, starting at tip or height if provided
    pub async fn get_address_balance(&self, address: String) -> Result<AddressBalance, ApiError> {
        Ok(self.inner.get_address_balance(address).await?)
    }

    /// Get a [`BlockHeader`] given a particular block hash.
    pub async fn get_scripthash_transactions(
        &self,
        script_hash: String,
    ) -> Result<Vec<ApiTx>, ApiError> {
        Ok(self.inner.get_scripthash_transactions(script_hash).await?)
    }

    /// Get a [`BlockHeader`] given a particular block hash.
    pub async fn get_scripthash_transactions_at_transaction_id(
        &self,
        script_hash: String,
        transaction_id: String,
    ) -> Result<Vec<ApiTx>, ApiError> {
        Ok(self
            .inner
            .get_scripthash_transactions_at_transaction_id(script_hash, transaction_id)
            .await?)
    }
}

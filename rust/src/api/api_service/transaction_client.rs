use andromeda_api::{core::ApiClient, transaction::MempoolInfo};
pub use andromeda_bitcoin::Transaction as bdkTransaction;
use std::sync::Arc;

use super::proton_api_service::ProtonAPIService;
use crate::BridgeError;

pub struct TransactionClient {
    pub(crate) inner: Arc<andromeda_api::transaction::TransactionClient>,
}

impl TransactionClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(andromeda_api::transaction::TransactionClient::new(
                service.inner.clone(),
            )),
        }
    }

    pub async fn get_raw_transaction(&self, txid: String) -> Result<bdkTransaction, BridgeError> {
        Ok(self.inner.get_raw_transaction(txid).await?)
    }

    pub async fn get_mempool_info(&self) -> Result<MempoolInfo, BridgeError> {
        Ok(self.inner.get_mempool_info().await?)
    }
}

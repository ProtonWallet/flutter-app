use std::sync::Arc;

pub use andromeda_api::core::ApiClient;
use andromeda_api::price_graph::{PriceGraph, Timeframe};
use andromeda_api::settings::FiatCurrencySymbol as FiatCurrency;

use crate::BridgeError;

use super::proton_api_service::ProtonAPIService;

pub struct PriceGraphClient {
    pub(crate) inner: Arc<andromeda_api::price_graph::PriceGraphClient>,
}

impl PriceGraphClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(andromeda_api::price_graph::PriceGraphClient::new(
                service.inner.clone(),
            )),
        }
    }

    pub async fn get_graph_data(
        &self,
        fiat_currency: FiatCurrency,
        timeframe: Timeframe,
    ) -> Result<PriceGraph, BridgeError> {
        Ok(self.inner.get_graph_data(fiat_currency, timeframe).await?)
    }
}

use andromeda_api::{
    core::ApiClient,
    price_graph::{PriceGraph, Timeframe},
    settings::FiatCurrencySymbol as FiatCurrency,
};
use std::sync::Arc;

use super::proton_api_service::ProtonAPIService;
use crate::BridgeError;

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

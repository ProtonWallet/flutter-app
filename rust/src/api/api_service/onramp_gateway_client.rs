use std::{collections::HashMap, sync::Arc};

pub use andromeda_api::core::ApiClient;
use andromeda_api::payment_gateway::{
    ApiCountry, ApiSimpleFiatCurrency, GatewayProvider, PaymentMethod, Quote,
};

use crate::BridgeError;

use super::proton_api_service::ProtonAPIService;

pub struct OnRampGatewayClient {
    pub(crate) inner: Arc<andromeda_api::payment_gateway::PaymentGatewayClient>,
}

impl OnRampGatewayClient {
    pub fn new(service: &ProtonAPIService) -> Self {
        Self {
            inner: Arc::new(andromeda_api::payment_gateway::PaymentGatewayClient::new(
                service.inner.clone(),
            )),
        }
    }

    pub async fn get_countries(
        &self,
    ) -> Result<HashMap<GatewayProvider, Vec<ApiCountry>>, BridgeError> {
        Ok(self.inner.get_countries().await?)
    }

    pub async fn get_fiat_currencies(
        &self,
    ) -> Result<HashMap<GatewayProvider, Vec<ApiSimpleFiatCurrency>>, BridgeError> {
        Ok(self.inner.get_fiat_currencies().await?)
    }

    pub async fn get_payment_methods(
        &self,
        fiat_symbol: String,
    ) -> Result<HashMap<GatewayProvider, Vec<PaymentMethod>>, BridgeError> {
        Ok(self.inner.get_payment_methods(fiat_symbol).await?)
    }

    pub async fn get_public_api_key(
        &self,
        provider: GatewayProvider,
    ) -> Result<String, BridgeError> {
        Ok(self.inner.get_public_api_key(provider).await?)
    }

    pub async fn get_quotes(
        &self,
        amount: f64,
        fiat_currency: String,
        pay_method: Option<PaymentMethod>,
        provider: Option<GatewayProvider>,
    ) -> Result<HashMap<GatewayProvider, Vec<Quote>>, BridgeError> {
        Ok(self
            .inner
            .get_quotes(amount, fiat_currency, pay_method, provider)
            .await?)
    }

    pub async fn create_on_ramp_checkout(
        &self,
        amount: String,
        btc_address: String,
        fiat_currency: String,
        pay_method: PaymentMethod,
        provider: GatewayProvider,
    ) -> Result<String, BridgeError> {
        Ok(self
            .inner
            .create_on_ramp_checkout(amount, btc_address, fiat_currency, pay_method, provider)
            .await?)
    }
}

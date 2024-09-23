pub struct BuyBitcoin<T: WalletClientTrait> {
    wallet_client: Arc<T>,
}

impl BuyBitcoin {}
use async_trait::async_trait;
use std::collections::HashMap;

#[derive(Clone, Default)]
struct BuyBitcoinState {
    is_country_loaded: bool,
    is_currency_loaded: bool,
    is_quote_loaded: bool,
    is_quote_failed: bool,
    error: String,
    selected_model: SelectedModel,
    country_codes: Vec<String>,
    currency_names: Vec<String>,
    quotes: Vec<Quote>,
    supported_providers: Vec<String>,
    received: HashMap<String, String>,
}

#[derive(Clone, Default)]
struct SelectedModel {
    country: Country,
    fiat_currency: FiatCurrency,
    amount: String,
    provider: String,
    payment_method: String,
    quote: Option<Quote>,
    supported_payments: Vec<String>,
}

#[derive(Clone, Default)]
struct Country {
    code: String,
}

#[derive(Clone, Default)]
struct FiatCurrency {
    symbol: String,
    minimum_amount: String,
}

#[derive(Clone, Default)]
struct Quote {
    bitcoin_amount: String,
    payment_method: String,
}

struct GatewayDataProvider;

#[async_trait]
impl GatewayDataProvider {
    async fn get_countries(&self) -> Vec<String> {
        // Simulate fetching countries
        vec!["US".to_string(), "CA".to_string()]
    }

    async fn get_currencies(&self, provider: &str, country_code: &str) -> Vec<String> {
        // Simulate fetching currencies
        vec!["USD".to_string(), "CAD".to_string()]
    }

    async fn get_quotes(
        &self,
        fiat_currency: &str,
        amount: &str,
        providers: Vec<String>,
    ) -> HashMap<String, Vec<Quote>> {
        // Simulate fetching quotes
        let mut quotes = HashMap::new();
        quotes.insert(
            "Provider1".to_string(),
            vec![Quote {
                bitcoin_amount: "0.1".to_string(),
                payment_method: "PayPal".to_string(),
            }],
        );
        quotes
    }

    async fn get_cached_quote(
        &self,
        fiat_currency: &str,
        amount: &str,
        provider: &str,
    ) -> Option<Vec<Quote>> {
        // Simulate fetching cached quote
        Some(vec![Quote {
            bitcoin_amount: "0.1".to_string(),
            payment_method: "PayPal".to_string(),
        }])
    }

    fn get_api_country(&self, provider: &str, country_code: &str) -> Country {
        // Simulate API call
        Country {
            code: country_code.to_string(),
        }
    }

    fn get_api_country_fiat_currency(&self, provider: &str, fiat_currency: &str) -> FiatCurrency {
        // Simulate API call
        FiatCurrency {
            symbol: fiat_currency.to_string(),
            minimum_amount: "10".to_string(),
        }
    }
}

// Handler functions

async fn handle_load_country(
    mut state: BuyBitcoinState,
    gateway_data_provider: &GatewayDataProvider,
) -> BuyBitcoinState {
    state.is_country_loaded = false;
    state.error.clear();

    // Fetch countries and providers
    let countries = gateway_data_provider.get_countries().await;
    let supported_providers = vec!["Provider1".to_string(), "Provider2".to_string()];

    // Set default country
    let selected_country = state.selected_model.country.clone();
    let default_country =
        gateway_data_provider.get_api_country("Provider1", &selected_country.code);

    state.is_country_loaded = true;
    state.country_codes = countries;
    state.supported_providers = supported_providers;
    state.selected_model.country = default_country;

    state
}

async fn handle_load_currency(
    mut state: BuyBitcoinState,
    gateway_data_provider: &GatewayDataProvider,
) -> BuyBitcoinState {
    state.is_currency_loaded = false;
    state.error.clear();

    let selected_provider = &state.selected_model.provider;
    let selected_country = &state.selected_model.country;

    // Fetch currencies
    let currencies = gateway_data_provider
        .get_currencies(selected_provider, &selected_country.code)
        .await;

    let default_currency = gateway_data_provider
        .get_api_country_fiat_currency(selected_provider, &selected_country.code);

    state.is_currency_loaded = true;
    state.currency_names = currencies;
    state.selected_model.fiat_currency = default_currency;

    state
}

async fn handle_select_country(
    mut state: BuyBitcoinState,
    country_code: String,
    gateway_data_provider: &GatewayDataProvider,
) -> BuyBitcoinState {
    let api_country =
        gateway_data_provider.get_api_country(&state.selected_model.provider, &country_code);
    state.selected_model.country = api_country;

    state
}

async fn handle_select_currency(
    mut state: BuyBitcoinState,
    currency: String,
    gateway_data_provider: &GatewayDataProvider,
) -> BuyBitcoinState {
    let fiat_currency = gateway_data_provider
        .get_api_country_fiat_currency(&state.selected_model.provider, &currency);

    state.selected_model.fiat_currency = fiat_currency;

    state
}

async fn handle_select_amount(mut state: BuyBitcoinState, amount: String) -> BuyBitcoinState {
    state.selected_model.amount = amount.replace(|c: char| !c.is_numeric(), "");
    state
}

async fn handle_get_quote(
    mut state: BuyBitcoinState,
    gateway_data_provider: &GatewayDataProvider,
) -> BuyBitcoinState {
    state.is_quote_loaded = false;
    state.is_quote_failed = false;

    let fiat_currency = &state.selected_model.fiat_currency.symbol;
    let amount = &state.selected_model.amount;
    let providers = state.supported_providers.clone();

    let quotes = gateway_data_provider
        .get_quotes(fiat_currency, amount, providers)
        .await;

    // Check for quotes and handle success/failure
    if quotes.is_empty() {
        state.is_quote_failed = true;
        state.error = format!("No quotes available for {} {}", amount, fiat_currency);
    } else {
        state.is_quote_loaded = true;
        state.quotes = quotes
            .get(&state.selected_model.provider)
            .unwrap_or(&vec![])
            .clone();
    }

    state
}

async fn handle_select_provider(
    mut state: BuyBitcoinState,
    provider: String,
    gateway_data_provider: &GatewayDataProvider,
) -> BuyBitcoinState {
    state.is_quote_loaded = false;
    state.is_quote_failed = false;

    let fiat_currency = &state.selected_model.fiat_currency.symbol;
    let amount = &state.selected_model.amount;

    let quote = gateway_data_provider
        .get_cached_quote(fiat_currency, amount, &provider)
        .await;

    if let Some(quote) = quote {
        state.quotes = quote.clone();
        state.selected_model.provider = provider;
    } else {
        state.is_quote_failed = true;
    }

    state
}

async fn handle_select_payment_method(
    mut state: BuyBitcoinState,
    payment_method: String,
    gateway_data_provider: &GatewayDataProvider,
) -> BuyBitcoinState {
    let provider = &state.selected_model.provider;
    let amount = &state.selected_model.amount;
    let fiat_currency = &state.selected_model.fiat_currency.symbol;

    if let Some(quote) = gateway_data_provider
        .get_cached_quote(fiat_currency, amount, provider)
        .await
    {
        let selected_quote = quote
            .into_iter()
            .find(|q| q.payment_method == payment_method)
            .unwrap_or(quote.first().cloned().unwrap());

        state.selected_model.payment_method = payment_method;
        state.selected_model.quote = Some(selected_quote);
    }

    state
}




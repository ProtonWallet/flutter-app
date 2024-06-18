use andromeda_api::settings::FiatCurrencySymbol as FiatCurrency;
use flutter_rust_bridge::frb;

//
pub use andromeda_api::payment_gateway::{
    ApiCountry, ApiFiatCurrency as ApiCountryFiatCurrency, CountriesByProvider, GatewayProvider,
    PaymentMethod, Quote,
};

#[frb(mirror(GatewayProvider))]
pub enum _GatewayProvider {
    Banxa,
    Ramp,
    MoonPay,
    Unsupported,
}

#[frb(mirror(PaymentMethod))]
pub enum _PaymentMethod {
    ApplePay = 1,
    BankTransfer = 2,
    Card = 3,
    GooglePay = 4,
    InstantPayment = 5,
    Unsupported,
}
#[frb(mirror(ApiCountry))]
#[allow(non_snake_case)]
pub struct _ApiCountry {
    pub Code: String,
    pub FiatCurrency: String,
    pub Name: String,
}

#[frb(mirror(ApiCountryFiatCurrency))]
#[allow(non_snake_case)]
pub struct _ApiCountryFiatCurrency {
    pub Name: String,
    pub Symbol: String,
}

#[frb(mirror(Quote))]
#[allow(non_snake_case)]
pub struct _Quote {
    pub BitcoinAmount: String,
    pub FiatAmount: String,
    pub FiatCurrencySymbol: FiatCurrency,
    pub NetworkFee: String,
    pub PaymentGatewayFee: String,
    pub PaymentMethod: PaymentMethod,
}

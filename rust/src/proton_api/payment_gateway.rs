use flutter_rust_bridge::frb;

//
pub use andromeda_api::payment_gateway::{
    ApiCountry, ApiSimpleFiatCurrency, CountriesByProvider, GatewayProvider, PaymentMethod, Quote,
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
    Paypal = 6,
    Unsupported,
}
#[frb(mirror(ApiCountry))]
#[allow(non_snake_case)]
pub struct _ApiCountry {
    pub Code: String,
    pub FiatCurrency: String,
    pub Name: String,
}

#[frb(mirror(ApiSimpleFiatCurrency))]
#[allow(non_snake_case)]
pub struct _ApiSimpleFiatCurrency {
    pub Name: String,
    pub Symbol: String,
    pub MinimumAmount: Option<String>,
}

#[frb(mirror(Quote))]
#[allow(non_snake_case)]
pub struct _Quote {
    pub BitcoinAmount: String,
    pub FiatAmount: String,
    pub FiatCurrencySymbol: String,
    pub NetworkFee: String,
    pub PaymentGatewayFee: String,
    pub PaymentMethod: PaymentMethod,
    // new added
    pub PurchaseAmount: Option<String>,
    pub PaymentProcessingFee: Option<String>,
    pub OrderID: Option<String>,
}
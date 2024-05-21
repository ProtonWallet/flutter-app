pub use andromeda_api::{exchange_rate::ApiExchangeRate, settings::FiatCurrencySymbol as FiatCurrency};
use andromeda_common::BitcoinUnit;
#[derive(Debug)]
pub struct ProtonExchangeRate {
    /// An encrypted ID
    pub id: String,
    /// Bitcoin unit of the exchange rate
    pub bitcoin_unit: BitcoinUnit,
    /// Fiat currency of the exchange rate
    pub fiat_currency: FiatCurrency,
    /// string <date-time>
    pub exchange_rate_time: String,
    /// Exchange rate BitcoinUnit/FiatCurrency
    pub exchange_rate: u64,
    /// Cents precision of the fiat currency (e.g. 1 for JPY, 100 for USD)
    pub cents: u64,
}

impl From<ApiExchangeRate> for ProtonExchangeRate {
    fn from(exchange_rate: ApiExchangeRate) -> Self {
        ProtonExchangeRate {
            id: exchange_rate.ID,
            bitcoin_unit: exchange_rate.BitcoinUnit,
            fiat_currency: exchange_rate.FiatCurrency,
            exchange_rate_time: exchange_rate.ExchangeRateTime,
            exchange_rate: exchange_rate.ExchangeRate,
            cents: exchange_rate.Cents,
        }
    }
}

use andromeda_api::{exchange_rate::ApiExchangeRate, settings::FiatCurrencySymbol as FiatCurrency};
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
impl From<ProtonExchangeRate> for ApiExchangeRate {
    fn from(exchange_rate: ProtonExchangeRate) -> Self {
        ApiExchangeRate {
            ID: exchange_rate.id,
            BitcoinUnit: exchange_rate.bitcoin_unit,
            FiatCurrency: exchange_rate.fiat_currency,
            ExchangeRateTime: exchange_rate.exchange_rate_time,
            ExchangeRate: exchange_rate.exchange_rate,
            Cents: exchange_rate.cents,
            Sign: None,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn mock_api_exchange_rate() -> ApiExchangeRate {
        ApiExchangeRate {
            ID: "test_id".to_string(),
            BitcoinUnit: BitcoinUnit::BTC,
            FiatCurrency: FiatCurrency::USD,
            ExchangeRateTime: "2024-10-22T12:00:00Z".to_string(),
            ExchangeRate: 45000,
            Cents: 100,
            Sign: None,
        }
    }

    #[test]
    fn test_conversion_from_api_exchange_rate() {
        let api_exchange_rate = mock_api_exchange_rate();
        let proton_exchange_rate: ProtonExchangeRate = api_exchange_rate.into();

        assert_eq!(proton_exchange_rate.id, "test_id");
        assert_eq!(proton_exchange_rate.bitcoin_unit, BitcoinUnit::BTC);
        assert_eq!(proton_exchange_rate.fiat_currency, FiatCurrency::USD);
        assert_eq!(
            proton_exchange_rate.exchange_rate_time,
            "2024-10-22T12:00:00Z"
        );
        assert_eq!(proton_exchange_rate.exchange_rate, 45000);
        assert_eq!(proton_exchange_rate.cents, 100);
    }
}

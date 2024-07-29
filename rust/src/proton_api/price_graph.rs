pub use andromeda_api::price_graph::{DataPoint, PriceGraph, Timeframe};
pub use andromeda_api::settings::FiatCurrencySymbol as FiatCurrency;
pub use andromeda_common::BitcoinUnit;
use flutter_rust_bridge::frb;

#[frb(mirror(Timeframe))]
pub enum _Timeframe {
    OneDay,
    OneWeek,
    OneMonth,
    Unsupported,
}

#[frb(mirror(DataPoint))]
#[allow(non_snake_case)]
pub struct _DataPoint {
    pub ExchangeRate: u64,
    pub Cents: u8,
    pub Timestamp: u64,
}

#[frb(mirror(PriceGraph))]
#[allow(non_snake_case)]
pub struct _PriceGraph {
    pub FiatCurrency: FiatCurrency,
    pub BitcoinUnit: BitcoinUnit,
    pub GraphData: Vec<DataPoint>,
}

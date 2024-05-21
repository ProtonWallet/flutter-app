pub use andromeda_api::settings::FiatCurrencySymbol as FiatCurrency;
use andromeda_api::settings::UserSettings;
pub use andromeda_common::BitcoinUnit;
use flutter_rust_bridge::frb;

#[frb(mirror(FiatCurrency))]
pub enum _FiatCurrency {
    ALL,
    DZD,
    ARS,
    AMD,
    AUD,
    AZN,
    BHD,
    BDT,
    BYN,
    BMD,
    BOB,
    BAM,
    BRL,
    BGN,
    KHR,
    CAD,
    CLP,
    CNY,
    COP,
    CRC,
    HRK,
    CUP,
    CZK,
    DKK,
    DOP,
    EGP,
    EUR,
    GEL,
    GHS,
    GTQ,
    HNL,
    HKD,
    HUF,
    ISK,
    INR,
    IDR,
    IRR,
    IQD,
    ILS,
    JMD,
    JPY,
    JOD,
    KZT,
    KES,
    KWD,
    KGS,
    LBP,
    MKD,
    MYR,
    MUR,
    MXN,
    MDL,
    MNT,
    MAD,
    MMK,
    NAD,
    NPR,
    TWD,
    NZD,
    NIO,
    NGN,
    NOK,
    OMR,
    PKR,
    PAB,
    PEN,
    PHP,
    PLN,
    GBP,
    QAR,
    RON,
    RUB,
    SAR,
    RSD,
    SGD,
    ZAR,
    KRW,
    SSP,
    VES,
    LKR,
    SEK,
    CHF,
    THB,
    TTD,
    TND,
    TRY,
    UGX,
    UAH,
    AED,
    USD,
    UYU,
    UZS,
    VND,
}

#[frb(mirror(BitcoinUnit))]
pub enum _BitcoinUnit {
    /// 100,000,000 sats
    BTC,
    /// 100,000 sats
    MBTC,
    /// 1 sat
    SATS,
}

#[derive(Debug)]
pub struct ApiUserSettings {
    pub bitcoin_unit: BitcoinUnit,
    pub fiat_currency: FiatCurrency,
    pub hide_empty_used_addresses: u8,
    pub show_wallet_recovery: u8,
    pub two_factor_amount_threshold: Option<u64>,
}

impl From<UserSettings> for ApiUserSettings {
    fn from(value: UserSettings) -> Self {
        ApiUserSettings {
            bitcoin_unit: value.BitcoinUnit,
            fiat_currency: value.FiatCurrency,
            hide_empty_used_addresses: value.HideEmptyUsedAddresses,
            show_wallet_recovery: value.ShowWalletRecovery,
            two_factor_amount_threshold: value.TwoFactorAmountThreshold,
        }
    }
}

impl From<ApiUserSettings> for UserSettings {
    fn from(value: ApiUserSettings) -> Self {
        UserSettings {
            BitcoinUnit: value.bitcoin_unit,
            FiatCurrency: value.fiat_currency,
            HideEmptyUsedAddresses: value.hide_empty_used_addresses,
            ShowWalletRecovery: value.show_wallet_recovery,
            TwoFactorAmountThreshold: value.two_factor_amount_threshold,
        }
    }
}

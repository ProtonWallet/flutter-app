// use crate::proton_api::route::RoutePath;

// use super::api_service::ProtonAPIService;
// use muon::{
//     request::{JsonRequest, Request, Response},
//     session::RequestExt,
// };
// use serde::{Deserialize, Serialize};

// #[derive(Debug, Clone, Deserialize)]
// pub struct WalletUserSettings {
//     #[serde(rename(deserialize = "BitcoinUnit"))]
//     pub(crate) bitcoin_unit: String,

//     #[serde(rename(deserialize = "FiatCurrencyUnit"))]
//     pub(crate) fiat_currency_unit: String,

//     #[serde(rename(deserialize = "HideEmptyUsedAddresses"))]
//     pub(crate) hide_empty_used_addresses: u8,

//     #[serde(rename(deserialize = "ShowWalletRecovery"))]
//     pub(crate) show_wallet_recovery: u8,

//     #[serde(rename(deserialize = "TwoFactorAmountThreshold"))]
//     pub(crate) two_factor_amount_threshold: Option<i64>,
// }

// // #Response

// #[derive(Debug, Deserialize)]
// pub struct WalletUserSettingsResponse {
//     #[serde(rename(deserialize = "Code"))]
//     pub code: i64,
//     #[serde(rename(deserialize = "WalletUserSettings"))]
//     pub settings: WalletUserSettings,
// }

// #[derive(Debug, Deserialize)]
// pub struct WalletUserSettingsUpdateResponse {
//     // #[serde(rename(deserialize = "Code"))]
//     pub Code: i64,

//     pub Error: Option<String>,
// }

// // #Request
// #[derive(Debug, Clone, Serialize)]
// pub struct PreferredBTCUnitReq {
//     // New preferred symbol (BTC/MBTC/SATS)
//     #[serde(rename(serialize = "Symbol"))]
//     btc_unit: String,
// }

// // #Request
// #[derive(Debug, Clone, Serialize)]
// pub struct PreferredFiatCurrencyReq {
//     // New preferred symbol (BTC/MBTC/SATS)
//     #[serde(rename(serialize = "Symbol"))]
//     fiat_currency: String,
// }

// #[derive(Debug, Clone, Serialize)]
// struct TwoFactorAmountThresholdReq {
//     // New preferred symbol (BTC/MBTC/SATS)
//     #[serde(rename(serialize = "TwoFactorAmountThreshold"))]
//     threshold: u64,
// }

// #[derive(Debug, Clone, Serialize)]
// struct HideEmptyUsedAddressesReq {
//     // Hide empty used addresses
//     #[serde(rename(serialize = "HideEmptyUsedAddresses"))]
//     hide: i8,
// }

// impl HideEmptyUsedAddressesReq {
//     fn new_with_bool(value: bool) -> HideEmptyUsedAddressesReq {
//         let hide = if value { 1 } else { 0 };
//         HideEmptyUsedAddressesReq { hide }
//     }
// }

// pub(crate) trait UserSettingsRoute {
//     //Get the global wallet user settings [GET] /wallet/{_version}/settings
//     async fn get_walelt_user_settings(
//         &self,
//     ) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>>;
//     // Update preferred Bitcoin unit
//     async fn update_preferred_btc_unit(
//         &self,
//         symble: String,
//     ) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>>;
//     // Update preferred fiat currency //
//     // New preferred symbol (BTC/MBTC/SATS or EUR/CHF/USD)
//     async fn update_preferred_fiat_currency(
//         &self,
//         symble: String,
//     ) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>>;
//     // Update two-factor amount threshold
//     async fn update_twofa_amount_threshold(
//         &self,
//         threshold: u64,
//     ) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>>;
//     // Update hide empty used addresses
//     async fn update_hide_empty_used_addresses(
//         &self,
//         hide: bool,
//     ) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>>;
// }

// impl UserSettingsRoute for ProtonAPIService {
//     async fn get_walelt_user_settings(
//         &self,
//     ) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>> {
//         let path = format!("{}{}", self.get_wallet_path(), "/settings");
//         print!("path: {} \r\n", path);
//         let res: WalletUserSettingsResponse = JsonRequest::new(http::Method::GET, path)
//             .bind(self.session_ref())?
//             .send()
//             .await?
//             .body()?;
//         Ok(res)
//     }

//     async fn update_preferred_btc_unit(
//         &self,
//         symble: String,
//     ) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>> {
//         let req = PreferredBTCUnitReq { btc_unit: symble };

//         let path = format!("{}{}", self.get_wallet_path(), "/settings/currency/bitcoin");
//         let res: WalletUserSettingsResponse = JsonRequest::new(http::Method::PUT, path)
//             .body(req)?
//             .bind(self.session_ref())?
//             .send()
//             .await?
//             .body()?;
//         Ok(res)
//     }

//     async fn update_preferred_fiat_currency(
//         &self,
//         symble: String,
//     ) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>> {
//         let req = PreferredFiatCurrencyReq {
//             fiat_currency: symble,
//         };

//         let path = format!("{}{}", self.get_wallet_path(), "/settings/currency/fiat");
//         let res: WalletUserSettingsResponse = JsonRequest::new(http::Method::PUT, path)
//             .body(req)?
//             .bind(self.session_ref())?
//             .send()
//             .await?
//             .body()?;
//         Ok(res)
//     }

//     async fn update_twofa_amount_threshold(
//         &self,
//         threshold: u64,
//     ) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>> {
//         let req = TwoFactorAmountThresholdReq {
//             threshold: threshold,
//         };
//         let path = format!("{}{}", self.get_wallet_path(), "/settings/2fa/threshold");
//         let res: WalletUserSettingsResponse = JsonRequest::new(http::Method::PUT, path)
//             .body(req)?
//             .bind(self.session_ref())?
//             .send()
//             .await?
//             .body()?;
//         Ok(res)
//     }

//     async fn update_hide_empty_used_addresses(
//         &self,
//         hide: bool,
//     ) -> Result<WalletUserSettingsResponse, Box<dyn std::error::Error>> {
//         let req = HideEmptyUsedAddressesReq::new_with_bool(hide);
//         let path =
//             format!(
//                 "{}{}",
//                 self.get_wallet_path(),
//                 "/settings/addresses/used/hide"
//             );
//         let res = JsonRequest::new(http::Method::PUT, path)
//             .body(req)?
//             .bind(self.session_ref())?
//             .send()
//             .await?
//             .body()?;
//         Ok(res)
//     }
// }

// #[cfg(test)]
// mod test {
//     use crate::proton_api::{
//         api_service::ProtonAPIService, user_settings_routes::UserSettingsRoute,
//     };

//     #[tokio::test]
//     async fn test_get_walelt_user_settings() {
//         let mut api_service = ProtonAPIService::default();
//         api_service.login("pro", "pro").await.unwrap();

//         let result = api_service.get_walelt_user_settings().await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let wallet_settings_response = result.unwrap();
//         assert_eq!(wallet_settings_response.code, 1000);
//         assert_eq!(wallet_settings_response.settings.bitcoin_unit, "BTC");
//         assert_eq!(wallet_settings_response.settings.fiat_currency_unit, "CHF");
//         assert_eq!(
//             wallet_settings_response.settings.hide_empty_used_addresses,
//             1
//         );
//         assert_eq!(wallet_settings_response.settings.show_wallet_recovery, 0);
//     }

//     #[tokio::test]
//     async fn test_update_preferred_btc_unit() {
//         let mut api_service = ProtonAPIService::default();
//         api_service.login("pro", "pro").await.unwrap();

//         let result = api_service.update_preferred_btc_unit("BTC".into()).await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let wallet_settings_response = result.unwrap();
//         assert_eq!(wallet_settings_response.code, 1000);
//         assert_eq!(wallet_settings_response.settings.bitcoin_unit, "BTC");
//         assert_eq!(wallet_settings_response.settings.fiat_currency_unit, "CHF");
//         assert_eq!(
//             wallet_settings_response.settings.hide_empty_used_addresses,
//             1
//         );
//         assert_eq!(wallet_settings_response.settings.show_wallet_recovery, 0);
//     }

//     #[tokio::test]
//     async fn test_update_preferred_fiat_currency() {
//         let mut api_service: ProtonAPIService = ProtonAPIService::default();
//         api_service.login("pro", "pro").await.unwrap();

//         let result = api_service
//             .update_preferred_fiat_currency("CHF".into())
//             .await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let wallet_settings_response = result.unwrap();
//         assert_eq!(wallet_settings_response.code, 1000);
//         assert_eq!(wallet_settings_response.settings.bitcoin_unit, "BTC");
//         assert_eq!(wallet_settings_response.settings.fiat_currency_unit, "CHF");
//         assert_eq!(
//             wallet_settings_response.settings.hide_empty_used_addresses,
//             1
//         );
//         assert_eq!(wallet_settings_response.settings.show_wallet_recovery, 0);
//     }

//     #[tokio::test]
//     async fn test_update_twofa_amount_threshold() {
//         let mut api_service = ProtonAPIService::default();
//         api_service.login("pro", "pro").await.unwrap();

//         let result = api_service.update_twofa_amount_threshold(1000).await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let wallet_settings_response = result.unwrap();
//         assert_eq!(wallet_settings_response.code, 1000);
//         assert_eq!(wallet_settings_response.settings.bitcoin_unit, "BTC");
//         assert_eq!(wallet_settings_response.settings.fiat_currency_unit, "CHF");
//         assert_eq!(
//             wallet_settings_response.settings.hide_empty_used_addresses,
//             1
//         );
//         assert_eq!(wallet_settings_response.settings.show_wallet_recovery, 0);
//         assert_eq!(
//             wallet_settings_response
//                 .settings
//                 .two_factor_amount_threshold,
//             Some(1000)
//         );
//     }

//     #[tokio::test]
//     async fn test_update_hide_empty_used_addresses() {
//         let mut api_service = ProtonAPIService::default();
//         api_service.login("pro", "pro").await.unwrap();

//         let result = api_service.update_hide_empty_used_addresses(true).await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let wallet_settings_response = result.unwrap();
//         assert_eq!(wallet_settings_response.code, 1000);
//         assert_eq!(wallet_settings_response.settings.bitcoin_unit, "BTC");
//         assert_eq!(wallet_settings_response.settings.fiat_currency_unit, "CHF");
//         assert_eq!(
//             wallet_settings_response.settings.hide_empty_used_addresses,
//             1
//         );
//         assert_eq!(wallet_settings_response.settings.show_wallet_recovery, 0);
//     }
// }

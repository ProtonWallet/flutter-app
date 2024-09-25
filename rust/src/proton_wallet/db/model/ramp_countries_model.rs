// use rusqlite::{Result, Row};
// use serde::{Deserialize, Serialize};
// use serde_rusqlite::from_row;

// #[derive(Debug, Serialize, Deserialize)]
// pub struct RampCountriesModel {
//     pub code: String,
//     pub name: String,
//     pub card_payments_enabled: bool,
//     pub main_currency_code: String,
//     pub supported_assets: Option<Vec<String>>,
//     pub api_v3_supported_assets: Option<Vec<String>>,
// }

// impl ModelBase for RampCountriesModel {
//     fn from_row(row: &Row) -> Result<Self> {
//         Ok(from_row::<RampCountriesModel>(row).unwrap())
//     }
// }

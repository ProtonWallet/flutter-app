// use rusqlite::{Result, Row};
// use serde::{Deserialize, Serialize};
// use serde_rusqlite::from_row;

// #[derive(Debug, Serialize, Deserialize)]
// pub struct TransactionInfoModel {
//     pub id: Option<u32>,
//     pub external_transaction_id: Vec<u8>,
//     pub amount_in_sats: u32,
//     pub fee_in_sats: u32,
//     pub is_send: u32,
//     pub transaction_time: u32,
//     pub fee_mode: u32,
//     pub server_wallet_id: String,
//     pub server_account_id: String,
//     pub to_email: String,
//     pub to_bitcoin_address: String,
// }

// impl ModelBase for TransactionInfoModel {
//     fn from_row(row: &Row) -> Result<Self> {
//         Ok(from_row::<TransactionInfoModel>(row).unwrap())
//     }
// }

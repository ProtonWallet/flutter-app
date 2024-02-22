
// #[wasm_bindgen]
// use std::sync::{Arc, RwLock};

// use andromeda_bitcoin::account::Account;
// use bdk::database::MemoryDatabase as BdkMemoryDatabase;


pub struct RustAccount {
    pub inner: std::sync::Arc<std::sync::RwLock<andromeda_bitcoin::account::Account<bdk::database::SqliteDatabase>>>,
}

impl RustAccount {
    // pub fn get_inner(&self) -> Arc<RwLock<Account<bdk::database::MemoryDatabase>>> {
    //     self.inner.clone()
    // }

    // pub fn get_bitcoin_uri(
    //             &mut self,
    //             index: Option<u32>,
    //             amount: Option<u64>,
    //             label: Option<String>,
    //             message: Option<String>,
    //         ) -> Result<WasmPaymentLink, DetailledWasmError> {
    //             let account_inner = self.get_inner();
        
    //             let payment_link: WasmPaymentLink = account_inner
    //                 .write()
    //                 .expect("lock")
    //                 .get_bitcoin_uri(index, amount, label, message)
    //                 .map_err(|e| e.into())?
    //                 .into();
        
    //             Ok(payment_link)
    //         }
    pub fn get_balance(&self) -> Result<Balance, Error> {
        let result = self
            .inner
            .read()
            .expect("lock")
            .get_balance();
        match result {
            Ok(balance) => Ok(balance),
            Err(e) => Err(e),
        }
    }
}

// impl Into<WasmAccount> for &Arc<RwLock<Account<BdkMemoryDatabase>>> {
//     fn into(self) -> WasmAccount {
//         WasmAccount { inner: self.clone() }
//     }
// }

// #[wasm_bindgen]
// impl WasmAccount {
//     #[wasm_bindgen(js_name = getBitcoinUri)]
//     

//     #[wasm_bindgen]
//     pub fn owns(&self, address: &WasmAddress) -> Result<bool, DetailledWasmError> {
//         let owns = self
//             .inner
//             .read()
//             .expect("lock")
//             .owns(&address.into())
//             .map_err(|e| e.into())?;

//         Ok(owns)
//     }

//     #[wasm_bindgen(js_name = getBalance)]


//     #[wasm_bindgen(js_name = getDerivationPath)]
//     pub fn get_derivation_path(&self) -> Result<String, DetailledWasmError> {
//         let derivation_path = self.inner.read().expect("lock").get_derivation_path().to_string();

//         Ok(derivation_path)
//     }

//     #[wasm_bindgen(js_name = getUtxos)]
//     pub fn get_utxos(&self) -> Result<IWasmUtxoArray, DetailledWasmError> {
//         let utxos = self
//             .inner
//             .read()
//             .expect("lock")
//             .get_utxos()
//             .map_err(|e| e.into())?
//             .into_iter()
//             .map(|utxo| utxo.into())
//             .collect::<Vec<WasmUtxo>>();

//         Ok(serde_wasm_bindgen::to_value(&utxos).unwrap().into())
//     }

//     #[wasm_bindgen(js_name = getTransactions)]
//     pub fn get_transactions(
//         &self,
//         pagination: Option<WasmPagination>,
//     ) -> Result<IWasmSimpleTransactionArray, DetailledWasmError> {
//         let transactions = self
//             .inner
//             .read()
//             .expect("lock")
//             .get_transactions(pagination.map(|pa| pa.into()), true)
//             .map_err(|e| e.into())?
//             .into_iter()
//             .map(|tx| {
//                 let wasm_tx: WasmSimpleTransaction = tx.into();
//                 wasm_tx
//             })
//             .collect::<Vec<_>>();

//         Ok(serde_wasm_bindgen::to_value(&transactions).unwrap().into())
//     }

//     #[wasm_bindgen(js_name = getTransaction)]
//     pub fn get_transaction(&self, txid: String) -> Result<WasmTransactionDetails, DetailledWasmError> {
//         let transaction = self
//             .inner
//             .read()
//             .expect("lock")
//             .get_transaction(txid)
//             .map_err(|e| e.into())?;

//         Ok(transaction.into())
//     }
// }

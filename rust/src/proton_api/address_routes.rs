use muon::session::Session;
// "Code": 1000,
// "Balance": {
// "Address": "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa",
// "ChainFundedBitcoin": 284175,
// "ChainSpentBitcoin": 17492,
// "MempoolFundedBitcoin": 0,
// "MempoolSpentBitcoin": 0
// }

// struct Balance {
//     pub(crate) address: String,
//     pub(crate) chain_funded_bitcoin: u64,
//     pub(crate) chain_spent_bitcoin: u64,
//     pub(crate) mempool_funded_bitcoin: u64,
//     pub(crate) mempool_spent_bitcoin: u64,
// }

// pub struct BalanceResponse {
//     pub code: i64,
//     pub(crate) balances: Balance,
// }
struct AddressClient {
    pub(crate) session: Session,
}

// impl AddressRoute for AddressClient {
//     async fn get_balance(self) -> Result<BalanceResponse, Box<dyn std::error::Error>> {
//         todo!()
//     }
// }
// pub(crate) trait AddressRoute {
//     async fn get_balance(self) -> Result<BalanceResponse, Box<dyn std::error::Error>>;
// }

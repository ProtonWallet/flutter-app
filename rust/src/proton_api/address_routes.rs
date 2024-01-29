use serde::Deserialize;

use super::api_service::ProtonAPIService;

#[derive(Debug, Clone, Deserialize)]
struct AddressBalance {
    pub(crate) address: String,
    pub(crate) chain_funded_bitcoin: u64,
    pub(crate) chain_spent_bitcoin: u64,
    pub(crate) mempool_funded_bitcoin: u64,
    pub(crate) mempool_spent_bitcoin: u64,
}

#[derive(Debug, Clone, Deserialize)]
pub struct AddressBalanceResponse {
    pub code: i64,
    pub(crate) balances: AddressBalance,
}

// {
//     "Code": 1000,
//     "Transactions": [
//       {
//         "TransactionId": "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b",
//         "Version": 2,
//         "Locktime": 2573037,
//         "Vin": [
//           {
//             "TransactionId": "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b",
//             "Vout": 8,
//             "Prevout": {
//               "ScriptPubKey": "00142ad4ad51b5b3c027626607194952e76fb3c48d6b",
//               "ScriptPubKeyAsm": "OP_0 OP_PUSHBYTES_20 2ad4ad51b5b3c027626607194952e76fb3c48d6",
//               "ScriptPubKeyType": "v0_p2wpkh",
//               "ScriptPubKeyAddress": "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa",
//               "Value": 8000
//             },
//             "ScriptSig": "160014d4e4999f1540e3413460f013023e2d4c077e9d18",
//             "ScriptSigAsm": "OP_PUSHBYTES_22 0014d4e4999f1540e3413460f013023e2d4c077e9d18",
//             "Witness": [
//               "3044022057a73ec9ddf9299e38a5344129614626ec141747a93e1dcdb4339c59e6bb822702206bed27b3c24cc0c0ba3d0f104e11871ed7529c490683132efa05beb7accdc98801"
//             ],
//             "InnerWitnessScriptAsm": "OP_0 OP_PUSHBYTES_20 d4e4999f1540e3413460f013023e2d4c077e9d18",
//             "IsCoinbase": 0,
//             "Sequence": 4294967293,
//             "InnerRedeemScriptAsm": "OP_0 OP_PUSHBYTES_20 d4e4999f1540e3413460f013023e2d4c077e9d18"
//           }
//         ],
//         "Vout": [
//           {
//             "ScriptPubKey": "00142ad4ad51b5b3c027626607194952e76fb3c48d6b",
//             "ScriptPubKeyAsm": "OP_0 OP_PUSHBYTES_20 2ad4ad51b5b3c027626607194952e76fb3c48d6",
//             "ScriptPubKeyType": "v0_p2wpkh",
//             "ScriptPubKeyAddress": "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa",
//             "Value": 8000
//           }
//         ],
//         "Size": 192,
//         "Weight": 441,
//         "Fee": 111,
//         "TransactionStatus": {
//           "IsConfirmed": 1,
//           "BlockHeight": 822030,
//           "BlockHash": "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
//           "BlockTime": 1704693916
//         }
//       }
//     ]
//   }

#[derive(Debug, Clone, Deserialize)]
struct Transaction {
    transaction_id: String,
    version: u64,
    locktime: u64,
    // vin: Vec<TransactionInput>,
    // vout: Vec<TransactionOutput>,
    size: u64,
    weight: u64,
    fee: u64,
    // transaction_status: TransactionStatus,
}

#[derive(Debug, Clone, Deserialize)]
pub struct AddressTranscationsResponse {
    pub code: i64,
    pub(crate) transactions: Vec<Transaction>,
}

pub(crate) trait AddressRoute {
    // Get balance of a Bitcoin address
    async fn get_address_balance(
        self,
    ) -> Result<AddressBalanceResponse, Box<dyn std::error::Error>>;
    // Get confirmed transaction history for an SHA-256 hash of a P2SH address
    async fn get_confirmed_tx_history(
        self,
    ) -> Result<AddressBalanceResponse, Box<dyn std::error::Error>>;
    // Get confirmed transaction by trans id for an SHA-256 hash of a P2SH address
    async fn get_confirmed_tx_by_id(
        self,
    ) -> Result<AddressBalanceResponse, Box<dyn std::error::Error>>;
}

impl AddressRoute for ProtonAPIService {
    async fn get_address_balance(
        self,
    ) -> Result<AddressBalanceResponse, Box<dyn std::error::Error>> {
        todo!()
    }

    async fn get_confirmed_tx_history(
        self,
    ) -> Result<AddressBalanceResponse, Box<dyn std::error::Error>> {
        todo!()
    }

    async fn get_confirmed_tx_by_id(
        self,
    ) -> Result<AddressBalanceResponse, Box<dyn std::error::Error>> {
        todo!()
    }
}

#[cfg(test)]
mod test {
    
}

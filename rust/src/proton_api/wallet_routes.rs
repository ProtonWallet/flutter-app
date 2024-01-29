use super::{api_service::ProtonAPIService, types::ResponseCode};


// {
//     "Code": 1000,
//     "Wallets": [
//       {
//         "Wallet": {
//           "ID": "string",
//           "HasPassphrase": 0,
//           "IsImported": 0,
//           "Mnemonic": "<base64_encoded_mnemonic>",
//           "Name": "My awesome on-chain wallet",
//           "Priority": 1,
//           "PublicKey": "<base64_encoded_publickey>",
//           "Status": 0,
//           "Type": 1
//         },
//         "WalletKey": {
//           "UserKeyID": "string",
//           "WalletKey": "string"
//         },
//         "WalletSettings": {
//           "HideAccounts": 0,
//           "InvoiceDefaultDescription": "Lightning payment from John Doe.",
//           "InvoiceExpirationTime": 3600,
//           "MaxChannelOpeningFee": 5000
//         }
//       }
//     ]
//   }





pub(crate) trait WalletRoute {
    async fn get_walelts(self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    async fn create_wallet(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
}


impl WalletRoute for ProtonAPIService {
    async fn get_walelts(self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        todo!()
    }

    async fn create_wallet(&self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        todo!()
    }
}


#[cfg(test)]
mod test {
    use crate::proton_api::{
        api_service::ProtonAPIService, transactions_routes::TransactionRoute
    };

    #[tokio::test]
    async fn test_test_three() {
        
    }
}

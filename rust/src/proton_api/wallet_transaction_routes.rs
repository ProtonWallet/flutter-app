use super::{api_service::ProtonAPIService, types::ResponseCode};

// {
//     "Code": 1000,
//     "WalletTransactions": [
//       {
//         "ID": "string",
//         "WalletID": "string",
//         "Label": "string",
//         "TransactionID": "string"
//       }
//     ]
//   }
pub(crate) trait WalletTransactionRoute {
    // Get transactions
    async fn get_transactions(self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    // Create transaction
    async fn create_transaction(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    // Update transaction label
    async fn update_transaction_label(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    // Delete transaction
    async fn delete_transaction(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
}

impl WalletTransactionRoute for ProtonAPIService {
    async fn get_transactions(self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        todo!()
    }

    async fn create_transaction(&self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        todo!()
    }

    async fn update_transaction_label(&self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        todo!()
    }

    async fn delete_transaction(&self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        todo!()
    }
}

// #[cfg(test)]
// mod test {
//     use crate::proton_api::{
//         api_service::ProtonAPIService, transactions_routes::TransactionRoute
//     };

//     #[tokio::test]
//     async fn test_test_three() {
//         let mut api_service = ProtonAPIService::default();
//         api_service.login("feng100", "12345678").await.unwrap();

//         let result = api_service.test_three().await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let auth_response = result.unwrap();
//         assert_eq!(auth_response.Code, 1000);
//         assert_eq!(auth_response.Network, 1);
//     }
// }

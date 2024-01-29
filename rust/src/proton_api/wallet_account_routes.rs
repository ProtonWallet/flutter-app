use super::{api_service::ProtonAPIService, types::ResponseCode};

pub(crate) trait WalletAccountRoute {
    async fn get_walelts(self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    async fn create_wallet(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
}

impl WalletAccountRoute for ProtonAPIService {
    async fn get_walelts(self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        todo!()
    }

    async fn create_wallet(&self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
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

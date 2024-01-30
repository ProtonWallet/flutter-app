use muon::{request::{JsonRequest, Response}, session::RequestExt};


use super::{api_service::ProtonAPIService, types::ResponseCode};

pub(crate) trait TransactionRoute {
    async fn test_one(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    async fn test_two(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
}

impl TransactionRoute for ProtonAPIService {
    async fn test_one(&self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        let res: ResponseCode = JsonRequest::new(http::Method::GET, "/tests/ping")
        .bind(self.session_ref())?
        .send()
        .await?
        .body()?;
    Ok(res)
    }

    async fn test_two(&self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        todo!()
    }

    // async fn test_three(&self) -> Result<NetworkResponse, Box<dyn std::error::Error>> {
    //     let path = format!("{}{}", "/wallet/v1", "/network");
    //     print!("path: {}", path);
    //     let res: NetworkResponse = JsonRequest::new(http::Method::GET, path)
    //         .bind(self.session_ref())?
    //         .send()
    //         .await?
    //         .body()?;
    //     Ok(res)
    // }
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

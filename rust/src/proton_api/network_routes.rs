use muon::{
    request::{JsonRequest, Response},
    session::RequestExt,
};
use serde::Deserialize;

use crate::proton_api::{api_service::ProtonAPIService, route::RoutePath, types::ResponseCode};

#[derive(Debug, Clone, Deserialize)]
pub struct NetworkResponse {
    pub(crate) Code: i64,
    pub(crate) Network: i64,
}

#[derive(Debug, Clone, Deserialize)]
pub struct NetworkResponseError {
    pub(crate) Code: i64,
    pub(crate) Error: String,
}

pub trait NetworkRoute {
    // Get network type [GET] /wallet/{_version}/network
    async fn get_network_type(&self) -> Result<NetworkResponse, Box<dyn std::error::Error>>;
    // Get server ping
    async fn ping_object(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    // Get server ping
    async fn ping(&self) -> Result<i32, Box<dyn std::error::Error>>;
}

impl NetworkRoute for ProtonAPIService {
    async fn ping(&self) -> Result<i32, Box<dyn std::error::Error>> {
        let res = JsonRequest::new(http::Method::GET, "/tests/ping")
            .bind(self.session_ref())?
            .send()
            .await?;

        Ok(res.status().as_u16() as i32)
    }

    async fn ping_object(&self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        let res: ResponseCode = JsonRequest::new(http::Method::GET, "/tests/ping")
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn get_network_type(&self) -> Result<NetworkResponse, Box<dyn std::error::Error>> {
        let path = format!("{}{}", self.get_wallet_path(), "/network");
        print!("path: {} \r\n", path);
        let res: NetworkResponse = JsonRequest::new(http::Method::GET, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }
}

#[cfg(test)]
mod test {
    use crate::proton_api::{api_service::ProtonAPIService, network_routes::NetworkRoute};

    #[tokio::test]
    async fn test_ping_ok() {
        let api_service = ProtonAPIService::default();
        let result = api_service.ping().await;
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), 200);
    }
    #[tokio::test]
    async fn test_ping_object_ok() {
        let api_service = ProtonAPIService::default();
        let result = api_service.ping_object().await;
        assert!(result.is_ok());
        assert_eq!(result.unwrap().code, 1000);
    }

    #[tokio::test]
    async fn test_get_network_ok() {
        let mut api_service = ProtonAPIService::default();
        api_service.login("feng100", "12345678").await.unwrap();

        let result = api_service.get_network_type().await;
        print!("{:?}", result);
        assert!(result.is_ok());
        let auth_response = result.unwrap();
        assert_eq!(auth_response.Code, 1000);
        assert_eq!(auth_response.Network, 1);
    }

    #[tokio::test]
    #[should_panic] //session issue
    async fn test_get_network_401() {
        let api_service = ProtonAPIService::default();
        api_service.get_network_type().await.unwrap();
    }
}

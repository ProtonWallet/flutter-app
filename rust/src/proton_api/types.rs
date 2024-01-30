use muon::types::auth::AuthInfoRes as MuonAuthInfoRes;
use serde::Deserialize;

#[derive(Debug, Clone)]
pub struct AuthInfo {
    pub code: i64,
    pub modulus: String,
    pub srp_session: String,
    pub salt: String,
    pub server_ephemeral: String,
}

impl From<MuonAuthInfoRes> for AuthInfo {
    fn from(x: MuonAuthInfoRes) -> Self {
        AuthInfo {
            code: x.Code.as_i64().unwrap_or_default(),
            modulus: x.Modulus,
            srp_session: x.SRPSession,
            salt: x.Salt,
            server_ephemeral: x.ServerEphemeral,
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct ResponseCode {
    #[serde(rename(deserialize = "Code"))]
    pub code: i32,
}

#[cfg(test)]
mod test {
    use crate::proton_api::{api_service::ProtonAPIService, transactions_routes::TransactionRoute};

    // #[tokio::test]
    // async fn test_test_three() {
    //     let mut api_service = ProtonAPIService::default();
    //     api_service.login("feng100", "12345678").await.unwrap();

    //     let result = api_service.test_three().await;
    //     print!("{:?}", result);
    //     assert!(result.is_ok());
    //     let auth_response = result.unwrap();
    //     assert_eq!(auth_response.Code, 1000);
    //     assert_eq!(auth_response.Network, 1);
    // }
}

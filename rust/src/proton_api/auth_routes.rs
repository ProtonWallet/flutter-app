use muon::{
    request::{JsonRequest, Request, Response},
    session::RequestExt,
    types::auth::{AuthInfoReq, AuthInfoRes},
};

use super::{api_service::ProtonAPIService, route::RoutePath};

pub(crate) trait AuthRoute {
    async fn fetch_auth_info(
        &self,
        user_name: String,
    ) -> Result<AuthInfoRes, Box<dyn std::error::Error>>;
}

impl AuthRoute for ProtonAPIService {
    async fn fetch_auth_info(
        &self,
        user_name: String,
    ) -> Result<AuthInfoRes, Box<dyn std::error::Error>> {
        let req =
            AuthInfoReq {
                Username: user_name,
            };

        let path = format!("{}{}", self.get_auth_path(), "/info");
        let res: AuthInfoRes = JsonRequest::new(http::Method::POST, path)
            .body(req)?
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;

        Ok(res)
    }
}

#[cfg(test)]
mod test {
    use serde_json::Number;
    use crate::proton_api::{api_service::ProtonAPIService, auth_routes::AuthRoute};

    #[tokio::test]
    async fn test_auth_info_ok() {
        let api_service = ProtonAPIService::default();
        let result = api_service.fetch_auth_info("feng100".into()).await;
        assert!(result.is_ok());
        let auth_response = result.unwrap();
        assert!(auth_response.Code == Number::from(1000));
        assert!(!auth_response.Modulus.is_empty());
        assert!(!auth_response.Salt.is_empty());
        assert!(!auth_response.ServerEphemeral.is_empty());
        assert!(!auth_response.SRPSession.is_empty());
    }
}

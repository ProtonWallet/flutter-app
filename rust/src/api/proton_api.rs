use std::sync::Arc;

use http::response;
use muon::auth::SimpleAuthStore;
use muon::request::{JsonRequest, Request, Response};
use muon::session::{RequestExt, Session};
use muon::types::auth::{AuthInfoReq, AuthInfoRes};
use muon::AppSpec;
// use http;

use crate::proton_api::api_service::ProtonAPIService;
use crate::proton_api::auth_routes::AuthRoute;
use crate::proton_api::errors::ApiError;
use crate::proton_api::network_routes::NetworkRoute;
use crate::proton_api::types::AuthInfo;
use crate::proton_api::wallet_routes::{CreateWalletReq, WalletRoute, WalletsResponse};

pub struct ProtonApi {}
impl ProtonApi {
    pub async fn create_proton_api() -> Result<String, ApiError> {
        ProtonAPIService::new_proton_api().map_err(|err| ApiError::Generic(err.to_string()))
    }

    pub async fn fetch_auth_info(api_id: String, user_name: String) -> Result<AuthInfo, ApiError> {
        let api = ProtonAPIService::retrieve_proton_api(api_id);
        let res = api
            .fetch_auth_info(user_name)
            .await
            .map_err(|err| ApiError::Generic(err.to_string()));
        Ok(res?.into())
        // ProtonAPIService::retrieve_proton_api(id).map_err(|err| ApiError::Generic(err.to_string())
    }
    // pub async fn login(api_id: String, user_name: String, password: String) -> Result<(), ApiError> {
    //     let api = ProtonAPIService::retrieve_proton_api(api_id);
    //     api.get_network_type().await.map_err(|err| ApiError::Generic(err.to_string()))?;
    //     api.login(&user_name, &password).await.map_err(|err| ApiError::Generic(err.to_string()))
    // }

    // wallets
    // pub async fn get_wallets(&mut self) -> Result<WalletsResponse, ApiError> {
    //     // let result = self.api.get_wallets().await;

    //     let result = self.api.get_wallets().await;

    //     match result {
    //         Ok(response) => Ok(response),
    //         Err(err) => Err(ApiError::Generic(err.to_string())),
    //     }

    //     // let res = match result {
    //     //     Ok(response) => response,
    //     //     Err(err) => ApiError::Generic(err.to_string()),
    //     // };

    //     // Ok(res)

    //     // .map_err(|err| ApiError::Generic(err.to_string()));
    //     // // print!("{:?}", result);
    //     // // assert!(result.is_ok());
    //     // // let wallet_settings_response = result.unwrap();
    //     // Ok(result)
    // }

    // pub async fn create_wallet(&mut self, wallet_req: CreateWalletReq) -> Result<(), ApiError> {
    //     let result = self.api.create_wallet(wallet_req).await;
    //     print!("{:?}", result);
    //     assert!(result.is_ok());
    //     let wallet_settings_response = result.unwrap();
    // }
}

// pub async fn fetch_auth_info(user_name: String) -> Result<AuthInfo, ApiError> {
//     let app = AppSpec::default();
//     let auth = SimpleAuthStore::new("atlas");
//     let session = Session::new(auth, app)?;

//     let req = AuthInfoReq {
//         Username: user_name,
//     };

//     let res: Result<AuthInfoRes, ApiError> = JsonRequest::new(http::Method::POST, "/auth/v4/info")
//         .body(req)
//         .map_err(|err| ApiError::Generic(err.to_string()))?
//         .bind(session)
//         .map_err(|err| ApiError::Generic(err.to_string()))?
//         .send()
//         .await
//         .map_err(|err| ApiError::Generic(err.to_string()))?
//         .body()
//         .map_err(|err| ApiError::Generic(err.to_string()));

//     Ok(res?.into())
// }

// create a global proton api service
// build functions
// pub fn init_api_service() {
//     // create a global proton api service
// }

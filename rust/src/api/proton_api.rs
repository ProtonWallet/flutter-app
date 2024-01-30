use std::sync::{Arc, RwLock};

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
use crate::proton_api::types::{AuthInfo, ResponseCode};
use crate::proton_api::wallet_account_routes::{
    CreateWalletAccountReq, WalletAccountResponse, WalletAccountRoute, WalletAccountsResponse,
};
use crate::proton_api::wallet_routes::{
    CreateWalletReq, CreateWalletResponse, WalletRoute, WalletsResponse,
};

use lazy_static::lazy_static;

lazy_static! {
    static ref PROTON_API: RwLock<Option<Arc<ProtonAPIService>>> = RwLock::new(None);
}

// build functions
pub async fn init_api_service(user_name: String, password: String) {
    // create a global proton api service
    let mut api = ProtonAPIService::default();
    api.login(&user_name, &password).await.unwrap();
    let mut api_ref = PROTON_API.write().unwrap();
    *api_ref = Some(Arc::new(api));
}

pub async fn fetch_auth_info(user_name: String) -> Result<AuthInfo, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let res = proton_api
        .fetch_auth_info(user_name)
        .await
        .map_err(|err| ApiError::Generic(err.to_string()));
    Ok(res?.into())
}

// wallets
pub async fn get_wallets() -> Result<WalletsResponse, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.get_wallets().await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(ApiError::Generic(err.to_string())),
    }
}

pub async fn create_wallet(wallet_req: CreateWalletReq) -> Result<CreateWalletResponse, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.create_wallet(wallet_req).await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(ApiError::Generic(err.to_string())),
    }
}

// wallet accounts
pub async fn get_wallet_accounts(wallet_id: String) -> Result<WalletAccountsResponse, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.get_wallet_accounts(wallet_id).await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(ApiError::Generic(err.to_string())),
    }
}

pub async fn create_wallet_account(
    wallet_id: String,
    req: CreateWalletAccountReq,
) -> Result<WalletAccountResponse, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.create_wallet_account(wallet_id, req).await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(ApiError::Generic(err.to_string())),
    }
}

pub async fn update_wallet_account_label(
    wallet_id: String,
    wallet_account_id: String,
    new_label: String,
) -> Result<WalletAccountResponse, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .update_wallet_account_label(wallet_id, wallet_account_id, new_label)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(ApiError::Generic(err.to_string())),
    }
}

pub async fn delete_wallet_account(
    wallet_id: String,
    wallet_account_id: String,
) -> Result<ResponseCode, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .delete_wallet_account(wallet_id, wallet_account_id)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(ApiError::Generic(err.to_string())),
    }
}

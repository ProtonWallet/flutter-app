use muon::{
    request::{JsonRequest, Request, Response},
    session::RequestExt,
};
use serde::{Deserialize, Serialize};

use crate::proton_api::route::RoutePath;

use super::{api_service::ProtonAPIService, types::ResponseCode};

#[derive(Debug, Serialize)]
pub struct CreateWalletAccountReq {
    // Label of the account
    Label: String,
    // Derivation path of the account
    DerivationPath: String,
    // Enum: 1 2 3 4
    ScriptType: i32,
}

#[derive(Debug, Deserialize)]
pub struct WalletAccount {
    ID: String,
    DerivationPath: String,
    Label: String,
    ScriptType: i32,
}

#[derive(Debug, Deserialize)]
pub struct WalletAccountsResponse {
    Code: i32,
    Accounts: Vec<WalletAccount>,
}

#[derive(Debug, Deserialize)]
pub struct WalletAccountResponse {
    Code: i32,
    Account: WalletAccount,
    // Error: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct UpdateWalletAccountLabelReq {
    // Label of the account
    Label: String,
}

pub(crate) trait WalletAccountRoute {
    //Get accounts
    async fn get_wallet_accounts(
        &self,
        wallet_id: String,
    ) -> Result<WalletAccountsResponse, Box<dyn std::error::Error>>;
    //Create account
    async fn create_wallet_account(
        &self,
        wallet_id: String,
        req: CreateWalletAccountReq,
    ) -> Result<WalletAccountResponse, Box<dyn std::error::Error>>;
    // Update account label
    async fn update_wallet_account_label(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        new_label: String,
    ) -> Result<WalletAccountResponse, Box<dyn std::error::Error>>;
    // Delete account
    async fn delete_wallet_account(
        &self,
        wallet_id: String,
        wallet_account_id: String,
    ) -> Result<ResponseCode, Box<dyn std::error::Error>>;
}

impl WalletAccountRoute for ProtonAPIService {
    async fn get_wallet_accounts(
        &self,
        wallet_id: String,
    ) -> Result<WalletAccountsResponse, Box<dyn std::error::Error>> {
        let path = format!("{}/wallets/{}/accounts", self.get_wallet_path(), wallet_id);
        print!("path: {} \r\n", path);
        let res = JsonRequest::new(http::Method::GET, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn create_wallet_account(
        &self,
        wallet_id: String,
        req: CreateWalletAccountReq,
    ) -> Result<WalletAccountResponse, Box<dyn std::error::Error>> {
        let path = format!("{}/wallets/{}/accounts", self.get_wallet_path(), wallet_id);
        print!("path: {} \r\n", path);
        let res = JsonRequest::new(http::Method::POST, path)
            .body(&req)?
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn update_wallet_account_label(
        &self,
        wallet_id: String,
        wallet_account_id: String,
        new_label: String,
    ) -> Result<WalletAccountResponse, Box<dyn std::error::Error>> {
        let path = format!(
            "{}/wallets/{}/accounts/{}/label",
            self.get_wallet_path(),
            wallet_id,
            wallet_account_id,
        );

        let req = UpdateWalletAccountLabelReq { Label: new_label };
        print!("path: {} \r\n", path);
        let res = JsonRequest::new(http::Method::PUT, path)
            .body(&req)?
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn delete_wallet_account(
        &self,
        wallet_id: String,
        wallet_account_id: String,
    ) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        let path = format!(
            "{}/wallets/{}/accounts/{}",
            self.get_wallet_path(),
            wallet_id,
            wallet_account_id
        );
        print!("path: {} \r\n", path);
        let res = JsonRequest::new(http::Method::DELETE, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }
}

#[cfg(test)]
mod test {
    use crate::proton_api::{
        api_service::ProtonAPIService,
        wallet_account_routes::{CreateWalletAccountReq, WalletAccountRoute},
    };

    #[tokio::test]
    async fn test_get_wallet_accounts() {
        let mut api_service = ProtonAPIService::default();
        api_service.login("pro", "pro").await.unwrap();

        let wallet_id = "pIJGEYyNFsPEb61otAc47_X8eoSeAfMSokny6dmg3jg2JrcdohiRuWSN2i1rgnkEnZmolVx4Np96IcwxJh1WNw==".to_string();
        let result = api_service.get_wallet_accounts(wallet_id).await;
        print!("{:?}", result);
        assert!(result.is_ok());
        let auth_response = result.unwrap();
        assert_eq!(auth_response.Code, 1000);
    }

    #[tokio::test]
    async fn test_create_wallet_account() {
        let mut api_service = ProtonAPIService::default();
        api_service.login("pro", "pro").await.unwrap();

        let wallet_id = "pIJGEYyNFsPEb61otAc47_X8eoSeAfMSokny6dmg3jg2JrcdohiRuWSN2i1rgnkEnZmolVx4Np96IcwxJh1WNw==".to_string();
        let req =
            CreateWalletAccountReq {
                Label: "dGVzdCB3YWxsZXQgYWNjb3VudA==".to_string(),
                DerivationPath: "m/84'/1'/0'".to_string(),
                ScriptType: 4,
            };
        let result = api_service.create_wallet_account(wallet_id, req).await;
        print!("{:?}", result);
        assert!(result.is_ok());
        let auth_response = result.unwrap();
        assert_eq!(auth_response.Code, 1000);
    }

    #[tokio::test]
    async fn test_update_wallet_account_label() {
        let mut api_service = ProtonAPIService::default();
        api_service.login("pro", "pro").await.unwrap();

        let wallet_id = "pIJGEYyNFsPEb61otAc47_X8eoSeAfMSokny6dmg3jg2JrcdohiRuWSN2i1rgnkEnZmolVx4Np96IcwxJh1WNw==".to_string();
        let wallet_account_id = "Ac3lBksHTrTEFUJ-LYUVg7Cx2xVLwjw_ZWMyVfYUKo7YFgTTWOj7uINQAGkjzM1HiadZfLDM9J6dJ_r3kJQZ5A==".to_string();
        let new_label = "dGVzdCB3YWxsZXQgYWNjb3VudA==".to_string();
        let result = api_service
            .update_wallet_account_label(wallet_id, wallet_account_id, new_label)
            .await;
        print!("{:?}", result);
        assert!(result.is_ok());
        let auth_response = result.unwrap();
        assert_eq!(auth_response.Code, 1000);
    }

    #[tokio::test]
    async fn test_delete_wallet_account() {
        let mut api_service = ProtonAPIService::default();
        api_service.login("pro", "pro").await.unwrap();

        let wallet_id = "pIJGEYyNFsPEb61otAc47_X8eoSeAfMSokny6dmg3jg2JrcdohiRuWSN2i1rgnkEnZmolVx4Np96IcwxJh1WNw==".to_string();
        let wallet_account_id = "tl_agT3IbWEsgnDJ0WBPVCEWUPSPQ02ep_lmBoFsJM-aGTy0ObCd7rdzObVhT02dEPGInv-y-zsymcQ1lQgTKQ==".to_string();
        let result = api_service.delete_wallet_account(wallet_id, wallet_account_id).await;
        print!("{:?}", result);
        assert!(result.is_ok());
        let auth_response = result.unwrap();
        assert_eq!(auth_response.code, 1000);
    }
}

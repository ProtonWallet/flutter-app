use muon::{
    request::{JsonRequest, Request, Response},
    session::RequestExt,
};
use serde::{Deserialize, Serialize};

use crate::proton_api::route::RoutePath;

use super::{api_service::ProtonAPIService, wallet_settings_routes::WalletSettings};

#[derive(Debug, Deserialize)]
struct ProtonWallet {
    ID: String,
    HasPassphrase: i32,
    IsImported: i32,
    Mnemonic: Option<String>,
    Name: String,
    Priority: i32,
    PublicKey: Option<String>,
    Status: i32,
    Type: i32,
}

#[derive(Debug, Deserialize)]
struct ProtonWalletKey {
    UserKeyID: String,
    WalletKey: String,
}

#[derive(Debug, Deserialize)]
pub struct WalletData {
    Wallet: ProtonWallet,
    WalletKey: ProtonWalletKey,
    WalletSettings: Option<WalletSettings>,
}

#[derive(Debug, Deserialize)]
pub struct WalletsResponse {
    Code: i32,
    Wallets: Vec<WalletData>,
}

#[derive(Debug, Deserialize)]
pub struct CreateWalletResponse {
    Code: i32,
    Wallet: ProtonWallet,
    WalletKey: ProtonWalletKey,
    WalletSettings: WalletSettings,
    // Error: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct CreateWalletReq {
    // Name of the wallet
    Name: String,
    // 0 if the wallet is created with Proton Wallet
    IsImported: i32,
    // Enum: 1 2
    Type: i32,
    // 1 if the wallet has a passphrase
    HasPassphrase: i32,
    //An encrypted ID
    UserKeyId: String,
    // Base64 encoded binary data
    WalletKey: String,
    // "<base64_encoded_mnemonic>",
    // Encrypted wallet mnemonic with the WalletKey, in base64 format
    Mnemonic: Option<String>,
    // "<base64_encoded_publickey>"
    // Encrypted wallet public key with the WalletKey, in base64 format
    PublicKey: Option<String>,
}

pub trait WalletRoute {
    async fn get_wallets(self) -> Result<WalletsResponse, Box<dyn std::error::Error>>;
    async fn create_wallet(
        &self,
        wallet_req: CreateWalletReq,
    ) -> Result<CreateWalletResponse, Box<dyn std::error::Error>>;
}

impl WalletRoute for ProtonAPIService {
    async fn get_wallets(self) -> Result<WalletsResponse, Box<dyn std::error::Error>> {
        let path = format!("{}{}", self.get_wallet_path(), "/wallets");
        print!("path: {} \r\n", path);
        let res = JsonRequest::new(http::Method::GET, path)
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn create_wallet(
        &self,
        wallet_req: CreateWalletReq,
    ) -> Result<CreateWalletResponse, Box<dyn std::error::Error>> {
        let path = format!("{}{}", self.get_wallet_path(), "/wallets");
        print!("path: {} \r\n", path);
        let res =
            JsonRequest::new(http::Method::POST, path)
                .body(&wallet_req)?
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
        wallet_routes::{CreateWalletReq, WalletRoute},
    };

    #[tokio::test]
    async fn test_get_walelts() {
        let mut api_service = ProtonAPIService::default();
        api_service.login("pro", "pro").await.unwrap();

        let result = api_service.get_wallets().await;
        print!("{:?}", result);
        assert!(result.is_ok());
        let wallet_settings_response = result.unwrap();
        assert_eq!(wallet_settings_response.Code, 1000);
    }

    #[tokio::test]
    #[ignore]
    async fn test_create_wallets() {
        let mut api_service = ProtonAPIService::default();
        api_service.login("pro", "pro").await.unwrap();

        let result = api_service
            .create_wallet(CreateWalletReq {
                Name: "Test wallet".into(),
                IsImported: 1,
                Type: 1,
                HasPassphrase: 0,
                UserKeyId: "base64 user key ID".into(),
                WalletKey: "base64 wallet key".into(),
                Mnemonic: Some("".into()), //not null
                PublicKey: Option::None,
            })
            .await;
        print!("{:?}", result);
        assert!(result.is_ok());
        let wallet_settings_response = result.unwrap();
        assert_eq!(wallet_settings_response.Code, 1000);
    }
}

use andromeda_api::wallet::{ApiWallet, ApiWalletKey, CreateWalletRequestBody};

use super::wallet_settings::WalletSettings;

#[derive(Debug)]
pub struct ProtonWallet {
    pub id: String,
    pub has_passphrase: u8,
    pub is_imported: u8,
    pub mnemonic: Option<String>,
    pub name: String,
    pub priority: u8,
    pub public_key: Option<String>,
    pub status: u8,
    pub r#type: u8,
    pub fingerprint: Option<String>,
}
impl From<ApiWallet> for ProtonWallet {
    fn from(wallet: ApiWallet) -> Self {
        ProtonWallet {
            id: wallet.ID,
            has_passphrase: wallet.HasPassphrase,
            is_imported: wallet.IsImported,
            mnemonic: wallet.Mnemonic,
            name: wallet.Name,
            priority: wallet.Priority,
            public_key: wallet.PublicKey,
            status: wallet.Status,
            r#type: wallet.Type,
            fingerprint: wallet.Fingerprint,
        }
    }
}

#[derive(Debug)]
pub struct ProtonWalletKey {
    pub user_key_id: String,
    pub wallet_key: String,
}
impl From<ApiWalletKey> for ProtonWalletKey {
    fn from(wallet_key: ApiWalletKey) -> Self {
        ProtonWalletKey {
            user_key_id: wallet_key.UserKeyID,
            wallet_key: wallet_key.WalletKey,
        }
    }
}

#[derive(Debug)]
pub struct WalletData {
    pub wallet: ProtonWallet,
    pub wallet_key: ProtonWalletKey,
    pub wallet_settings: WalletSettings,
}
impl From<andromeda_api::wallet::ApiWalletData> for WalletData {
    fn from(wallet_data: andromeda_api::wallet::ApiWalletData) -> Self {
        WalletData {
            wallet: wallet_data.Wallet.into(),
            wallet_key: wallet_data.WalletKey.into(),
            wallet_settings: wallet_data.WalletSettings.into(),
        }
    }
}

// #[derive(Debug, Deserialize)]
// pub struct WalletsResponse {
//     pub Code: i32,
//     pub Wallets: Vec<ApiWalletData>,
// }

// #[derive(Debug, Deserialize)]
// pub struct CreateWalletResponse {
//     pub Code: i32,
//     pub ApiWallet: ProtonWallet,
//     pub ApiWalletKey: ProtonWalletKey,
//     pub WalletSettings: WalletSettings,
//     // Error: Option<String>,
// }

#[derive(Debug)]
pub struct CreateWalletReq {
    // Name of the wallet
    pub name: String,
    // 0 if the wallet is created with Proton ApiWallet
    pub is_imported: u8,
    // Enum: 1 2
    pub r#type: u8,
    // 1 if the wallet has a passphrase
    pub has_passphrase: u8,
    //An encrypted ID
    pub user_key_id: String,
    // Base64 encoded binary data
    pub wallet_key: String,
    // "<base64_encoded_mnemonic>",
    // Encrypted wallet mnemonic with the ApiWalletKey, in base64 format
    pub mnemonic: Option<String>,
    // "<base64_encoded_publickey>"
    // Encrypted wallet public key with the ApiWalletKey, in base64 format
    pub public_key: Option<String>,

    pub fingerprint: Option<String>,
}

impl From<CreateWalletRequestBody> for CreateWalletReq {
    fn from(req: CreateWalletRequestBody) -> Self {
        CreateWalletReq {
            name: req.Name,
            is_imported: req.IsImported,
            r#type: req.Type,
            has_passphrase: req.HasPassphrase,
            user_key_id: req.UserKeyID,
            wallet_key: req.WalletKey,
            mnemonic: req.Mnemonic,
            public_key: req.PublicKey,
            fingerprint: req.Fingerprint,
        }
    }
}

impl From<CreateWalletReq> for CreateWalletRequestBody {
    fn from(req: CreateWalletReq) -> Self {
        CreateWalletRequestBody {
            Name: req.name,
            IsImported: req.is_imported,
            Type: req.r#type,
            HasPassphrase: req.has_passphrase,
            UserKeyID: req.user_key_id,
            WalletKey: req.wallet_key,
            Mnemonic: req.mnemonic,
            PublicKey: req.public_key,
            Fingerprint: req.fingerprint,
        }
    }
}

// pub trait WalletRoute {
//     async fn get_wallets(&self) -> Result<WalletsResponse, Box<dyn std::error::Error>>;
//     async fn create_wallet(
//         &self,
//         wallet_req: CreateWalletReq,
//     ) -> Result<CreateWalletResponse, Box<dyn std::error::Error>>;
// }
// #[cfg(test)]
// mod test {
//     use crate::proton_api::{
//         api_service::ProtonAPIService,
//         wallet_routes::{CreateWalletReq, WalletRoute},
//     };

//     #[tokio::test]
//     async fn test_get_walelts() {
//         let mut api_service = ProtonAPIService::default();
//         api_service.login("pro", "pro").await.unwrap();

//         let result = api_service.get_wallets().await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let wallet_settings_response = result.unwrap();
//         assert_eq!(wallet_settings_response.Code, 1000);
//     }

//     #[tokio::test]
//     #[ignore]
//     async fn test_create_wallets() {
//         let mut api_service = ProtonAPIService::default();
//         api_service.login("pro", "pro").await.unwrap();

//         let result = api_service
//             .create_wallet(CreateWalletReq {
//                 Name: "Test wallet".into(),
//                 IsImported: 1,
//                 Type: 1,
//                 HasPassphrase: 0,
//                 UserKeyId: "base64 user key ID".into(),
//                 ApiWalletKey: "base64 wallet key".into(),
//                 Mnemonic: Some("".into()), //not null
//                 PublicKey: Option::None,
//             })
//             .await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let wallet_settings_response = result.unwrap();
//         assert_eq!(wallet_settings_response.Code, 1000);
//     }
// }

use andromeda_api::wallet::{ApiWalletAccount, CreateWalletAccountRequestBody};

#[derive(Debug)]
pub struct CreateWalletAccountReq {
    // Label of the account
    pub label: String,
    // Derivation path of the account
    pub derivation_path: String,
    // Enum: 1 2 3 4
    pub script_type: u8,
}
// convert CreateWalletAccountReq to CreateWalletAccountRequestBody
impl From<CreateWalletAccountReq> for CreateWalletAccountRequestBody {
    fn from(req: CreateWalletAccountReq) -> Self {
        CreateWalletAccountRequestBody {
            DerivationPath: req.derivation_path,
            Label: req.label,
            ScriptType: req.script_type,
        }
    }
}
// convert CreateWalletAccountRequestBody to CreateWalletAccountReq
impl From<CreateWalletAccountRequestBody> for CreateWalletAccountReq {
    fn from(body: CreateWalletAccountRequestBody) -> Self {
        CreateWalletAccountReq {
            derivation_path: body.DerivationPath,
            label: body.Label,
            script_type: body.ScriptType,
        }
    }
}

#[derive(Debug)]
pub struct WalletAccount {
    pub id: String,
    pub wallet_id: String,
    pub derivation_path: String,
    pub label: String,
    pub script_type: u8,
}
impl From<WalletAccount> for ApiWalletAccount {
    fn from(wallet_account: WalletAccount) -> Self {
        ApiWalletAccount {
            ID: wallet_account.id,
            DerivationPath: wallet_account.derivation_path,
            Label: wallet_account.label,
            ScriptType: wallet_account.script_type,
            WalletID: wallet_account.wallet_id,
        }
    }
}
impl From<ApiWalletAccount> for WalletAccount {
    fn from(account: ApiWalletAccount) -> Self {
        WalletAccount {
            id: account.ID,
            derivation_path: account.DerivationPath,
            label: account.Label,
            // This cast is generally safe since u8 can fit into i32
            script_type: account.ScriptType,
            wallet_id: account.WalletID,
        }
    }
}

// #[derive(Debug)]
// pub struct WalletAccountsResponse {
//     pub code: i32,
//     pub accounts: Vec<WalletAccount>,
// }

// #[derive(Debug)]
// pub struct WalletAccountResponse {
//     pub code: i32,
//     pub api_wallet_account: WalletAccount,
// }

// #[derive(Debug)]
// pub struct UpdateWalletAccountLabelReq {
//     // Label of the account
//     pub label: String,
// }

// #[cfg(test)]
// mod test {
//     use crate::api::proton_api_service::ProtonAPIService;

//     #[tokio::test]
//     async fn test_get_wallet_accounts() {
//         let mut api_service = ProtonAPIService::new();
//         api_service.login("pro", "pro").await.unwrap();

//         let wallet_id = "pIJGEYyNFsPEb61otAc47_X8eoSeAfMSokny6dmg3jg2JrcdohiRuWSN2i1rgnkEnZmolVx4Np96IcwxJh1WNw==".to_string();
//         let result = api_service.get_wallet_accounts(wallet_id).await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let auth_response = result.unwrap();
//         assert_eq!(auth_response.Code, 1000);
//     }

//     #[tokio::test]
//     async fn test_create_wallet_account() {
//         let mut api_service = ProtonAPIService::default();
//         api_service.login("pro", "pro").await.unwrap();

//         let wallet_id = "pIJGEYyNFsPEb61otAc47_X8eoSeAfMSokny6dmg3jg2JrcdohiRuWSN2i1rgnkEnZmolVx4Np96IcwxJh1WNw==".to_string();
//         let req =
//             CreateWalletAccountReq {
//                 Label: "dGVzdCB3YWxsZXQgYWNjb3VudA==".to_string(),
//                 DerivationPath: "m/84'/1'/0'".to_string(),
//                 ScriptType: 4,
//             };
//         let result = api_service.create_wallet_account(wallet_id, req).await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let auth_response = result.unwrap();
//         assert_eq!(auth_response.Code, 1000);
//     }

//     #[tokio::test]
//     async fn test_update_wallet_account_label() {
//         let mut api_service = ProtonAPIService::default();
//         api_service.login("pro", "pro").await.unwrap();

//         let wallet_id = "pIJGEYyNFsPEb61otAc47_X8eoSeAfMSokny6dmg3jg2JrcdohiRuWSN2i1rgnkEnZmolVx4Np96IcwxJh1WNw==".to_string();
//         let wallet_account_id = "Ac3lBksHTrTEFUJ-LYUVg7Cx2xVLwjw_ZWMyVfYUKo7YFgTTWOj7uINQAGkjzM1HiadZfLDM9J6dJ_r3kJQZ5A==".to_string();
//         let new_label = "dGVzdCB3YWxsZXQgYWNjb3VudA==".to_string();
//         let result = api_service
//             .update_wallet_account_label(wallet_id, wallet_account_id, new_label)
//             .await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let auth_response = result.unwrap();
//         assert_eq!(auth_response.Code, 1000);
//     }

//     #[tokio::test]
//     async fn test_delete_wallet_account() {
//         let mut api_service = ProtonAPIService::default();
//         api_service.login("pro", "pro").await.unwrap();

//         let wallet_id = "pIJGEYyNFsPEb61otAc47_X8eoSeAfMSokny6dmg3jg2JrcdohiRuWSN2i1rgnkEnZmolVx4Np96IcwxJh1WNw==".to_string();
//         let wallet_account_id = "tl_agT3IbWEsgnDJ0WBPVCEWUPSPQ02ep_lmBoFsJM-aGTy0ObCd7rdzObVhT02dEPGInv-y-zsymcQ1lQgTKQ==".to_string();
//         let result = api_service.delete_wallet_account(wallet_id, wallet_account_id).await;
//         print!("{:?}", result);
//         assert!(result.is_ok());
//         let auth_response = result.unwrap();
//         assert_eq!(auth_response.code, 1000);
//     }
// }

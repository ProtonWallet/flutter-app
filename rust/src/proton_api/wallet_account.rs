pub use andromeda_api::wallet::{ApiEmailAddress, ApiWalletAccount};
use andromeda_api::{
    settings::FiatCurrencySymbol as FiatCurrency, wallet::CreateWalletAccountRequestBody,
};
use flutter_rust_bridge::frb;

#[derive(Debug, Clone)]
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

#[frb(mirror(ApiWalletAccount))]
#[allow(non_snake_case)]
pub struct _ApiWalletAccount {
    pub ID: String,
    pub WalletID: String,
    pub FiatCurrency: FiatCurrency,
    pub DerivationPath: String,
    pub Label: String,
    pub LastUsedIndex: u32,
    pub PoolSize: u32,
    pub Priority: u32,
    pub ScriptType: u8,
    pub Addresses: Vec<ApiEmailAddress>,
}

#[frb(mirror(ApiEmailAddress))]
#[allow(non_snake_case)]
pub struct _ApiEmailAddress {
    pub ID: String,
    pub Email: String,
}

#[cfg(test)]
mod tests {
    use super::*;
    use andromeda_api::wallet::CreateWalletAccountRequestBody;

    fn mock_create_wallet_account_req() -> CreateWalletAccountReq {
        CreateWalletAccountReq {
            label: "Test Account".to_string(),
            derivation_path: "m/44'/0'/0'/0".to_string(),
            script_type: 1,
        }
    }

    fn mock_create_wallet_account_request_body() -> CreateWalletAccountRequestBody {
        CreateWalletAccountRequestBody {
            Label: "Test Account".to_string(),
            DerivationPath: "m/44'/0'/0'/0".to_string(),
            ScriptType: 1,
        }
    }

    #[test]
    fn test_create_wallet_account_req_to_body_conversion() {
        let req = mock_create_wallet_account_req();
        let req_body: CreateWalletAccountRequestBody = req.clone().into();

        assert_eq!(req_body.Label, req.label);
        assert_eq!(req_body.DerivationPath, req.derivation_path);
        assert_eq!(req_body.ScriptType, req.script_type);
    }

    #[test]
    fn test_create_wallet_account_body_to_req_conversion() {
        let req_body = mock_create_wallet_account_request_body();
        let req: CreateWalletAccountReq = req_body.clone().into();

        assert_eq!(req.label, req_body.Label);
        assert_eq!(req.derivation_path, req_body.DerivationPath);
        assert_eq!(req.script_type, req_body.ScriptType);
    }
}

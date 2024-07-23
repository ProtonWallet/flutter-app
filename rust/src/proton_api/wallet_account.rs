pub use andromeda_api::wallet::{ApiEmailAddress, ApiWalletAccount};
use andromeda_api::{
    settings::FiatCurrencySymbol as FiatCurrency, wallet::CreateWalletAccountRequestBody,
};
use flutter_rust_bridge::frb;

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

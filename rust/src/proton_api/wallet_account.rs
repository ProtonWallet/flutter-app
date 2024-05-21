use andromeda_api::{
    settings::FiatCurrencySymbol as FiatCurrency,
    wallet::{ApiEmailAddress, ApiWalletAccount, CreateWalletAccountRequestBody},
};

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
    pub addresses: Vec<EmailAddress>,
    pub fiat_currency: FiatCurrency,
}

#[derive(Debug)]
pub struct EmailAddress {
    pub id: String,
    pub email: String,
}

impl From<EmailAddress> for ApiEmailAddress {
    fn from(email_address: EmailAddress) -> Self {
        ApiEmailAddress {
            ID: email_address.id,
            Email: email_address.email,
        }
    }
}

impl From<ApiEmailAddress> for EmailAddress {
    fn from(email_address: ApiEmailAddress) -> Self {
        EmailAddress {
            id: email_address.ID,
            email: email_address.Email,
        }
    }
}

impl From<WalletAccount> for ApiWalletAccount {
    fn from(wallet_account: WalletAccount) -> Self {
        ApiWalletAccount {
            ID: wallet_account.id,
            DerivationPath: wallet_account.derivation_path,
            Label: wallet_account.label,
            ScriptType: wallet_account.script_type,
            WalletID: wallet_account.wallet_id,
            Addresses: wallet_account
                .addresses
                .into_iter()
                .map(|v| v.into())
                .collect(),
            FiatCurrency: wallet_account.fiat_currency,
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
            addresses: account.Addresses.into_iter().map(|v| v.into()).collect(),
            fiat_currency: account.FiatCurrency,
        }
    }
}

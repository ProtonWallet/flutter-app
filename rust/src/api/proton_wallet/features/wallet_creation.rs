use andromeda_api::wallet::ApiWalletAccount;

use crate::{
    api::errors::BridgeError, proton_wallet::features::wallet::wallet_creation::WalletCreation,
};

pub struct FrbWalletCreation {
    pub(crate) inner: WalletCreation,
}

impl FrbWalletCreation {
    pub async fn create_wallet_account(
        &self,
        wallet_id: String,
        // script_type: &ScriptTypeInfo,
        label: String,
        // fiat_currency: &FiatCurrency,
        account_index: i32,
    ) -> Result<ApiWalletAccount, BridgeError> {
        Ok(self
            .inner
            .create_wallet_account(wallet_id, label, account_index)
            .await?)
    }
}

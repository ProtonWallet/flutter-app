use andromeda_api::wallet::{ApiWalletAccount, WalletClient};

use crate::{proton_wallet::features::wallet::wallet_creation::WalletCreation, BridgeError};

pub struct FrbWalletCreation {
    pub(crate) inner: WalletCreation<WalletClient>,
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

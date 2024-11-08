use andromeda_api::wallet::ApiWalletData;

pub struct MnemonicData {
    pub wallet_id: String,
    pub mnemonic: Option<String>,
}

impl From<ApiWalletData> for MnemonicData {
    fn from(value: ApiWalletData) -> Self {
        MnemonicData {
            wallet_id: value.Wallet.ID,
            mnemonic: value.Wallet.Mnemonic,
        }
    }
}

// Implement conversion from Vec<ApiWalletData> to Vec<MnemonicData>
pub(crate) struct WalletDatasWrap(pub(crate) Vec<ApiWalletData>);
impl From<WalletDatasWrap> for Vec<MnemonicData> {
    fn from(value: WalletDatasWrap) -> Self {
        value.0.into_iter().map(|item| item.into()).collect()
    }
}

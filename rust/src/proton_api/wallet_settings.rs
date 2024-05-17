use andromeda_api::wallet::ApiWalletSettings as CommonWalletSettings;

#[derive(Debug)]
pub struct WalletSettings {
    pub hide_accounts: u8,
    pub invoice_default_desc: Option<String>,
    pub invoice_exp_time: u64,
    pub max_channel_opening_fee: u64,
}

impl From<CommonWalletSettings> for WalletSettings {
    fn from(value: CommonWalletSettings) -> Self {
        WalletSettings {
            hide_accounts: value.HideAccounts,
            invoice_default_desc: value.InvoiceDefaultDescription,
            invoice_exp_time: value.InvoiceExpirationTime,
            max_channel_opening_fee: value.MaxChannelOpeningFee,
        }
    }
}

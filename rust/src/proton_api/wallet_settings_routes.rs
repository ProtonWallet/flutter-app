use muon::session::Session;

use super::types::ResponseCode;

pub(crate) struct WalletSettingsClinet {
    session: Session,
}

impl WalletSettingsClinet {
    fn new(session: Session) -> Self {
        WalletSettingsClinet {
            session,
        }
    }
}
pub(crate) trait WalletSettingsRoute {
    // Update hide account [PUT] /wallet/{_version}/wallets/{walletId}/settings/accounts/hide
    async fn update_hide_account(&self, hide: bool) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    // Update invoice default description [PUT] /wallet/{_version}/wallets/{walletId}/settings/invoices/description
    async fn update_invoice_default_desc(self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    // Update invoice expiration time [PUT] /wallet/{_version}/wallets/{walletId}/settings/invoices/expiration
    async fn update_invoice_exp_time(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
    // Update max channel opening fee [PUT] /wallet/{_version}/wallets/{walletId}/settings/channels/fee
    async fn update_max_opening_fee(&self) -> Result<ResponseCode, Box<dyn std::error::Error>>;
}

impl WalletSettingsRoute for WalletSettingsClinet {
    async fn update_hide_account(&self, hide: bool) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        unimplemented!()
    }
    async fn update_invoice_default_desc(self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        unimplemented!()
    }
    async fn update_invoice_exp_time(&self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        unimplemented!()
    }
    async fn update_max_opening_fee(&self) -> Result<ResponseCode, Box<dyn std::error::Error>> {
        unimplemented!()
    }
    
}
use muon::{
    request::{JsonRequest, Request, Response},
    session::RequestExt,
};

use super::{api_service::ProtonAPIService, route::RoutePath};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum HideAccount {
    on = 1,
    off = 0,
}

#[derive(Debug, Clone, Deserialize)]
pub struct WalletSettings {
    #[serde(rename(deserialize = "HideAccounts"))]
    hide_accounts: i8,
    #[serde(rename(deserialize = "InvoiceDefaultDescription"))]
    invoice_default_desc: Option<String>,
    #[serde(rename(deserialize = "InvoiceExpirationTime"))]
    invoice_exp_time: u64,
    #[serde(rename(deserialize = "MaxChannelOpeningFee"))]
    max_channel_opening_fee: u64,
}

// #Request

#[derive(Debug, Clone, Serialize)]
pub struct HideAccountsReq {
    // Hide accounts, only used for on-chain wallet
    #[serde(rename(serialize = "HideAccounts"))]
    hide_accounts: HideAccount,
}

#[derive(Debug, Clone, Serialize)]
pub struct InvoiceDescriptionReq {
    // Invoice default description, only used for lightning wallet
    #[serde(rename(serialize = "InvoiceDefaultDescription"))]
    invoice_default_desc: String,
}

#[derive(Debug, Clone, Serialize)]
pub struct InvoiceExpirationTimeReq {
    // Invoice expiration time, only used for lightning wallet
    #[serde(rename(serialize = "InvoiceExpirationTime"))]
    invoice_expiration_time: u64,
}

#[derive(Debug, Clone, Serialize)]
pub struct MaxChannelOpeningFeeReq {
    // Max fee for automatic channel opening with Proton Lightning node, expressed in SATS,
    //   only used for lightning wallet
    #[serde(rename(serialize = "MaxChannelOpeningFee"))]
    max_channel_opening_fee: u64,
}
// #Response

#[derive(Debug, Clone, Deserialize)]
pub struct WalletSettingsResponse {
    #[serde(rename(deserialize = "Code"))]
    code: i64,
    #[serde(rename(deserialize = "WalletSettings"))]
    settings: WalletSettings,
}

pub(crate) trait WalletSettingsRoute {
    // Update hide account [PUT] /wallet/{_version}/wallets/{walletId}/settings/accounts/hide
    async fn update_hide_account(
        &self,
        wallet_id: String,
        hide: HideAccount,
    ) -> Result<WalletSettingsResponse, Box<dyn std::error::Error>>;
    // Update invoice default description [PUT] /wallet/{_version}/wallets/{walletId}/settings/invoices/description
    async fn update_invoice_default_desc(
        &self,
        wallet_id: String,
        desc: String,
    ) -> Result<WalletSettingsResponse, Box<dyn std::error::Error>>;
    // Update invoice expiration time [PUT] /wallet/{_version}/wallets/{walletId}/settings/invoices/expiration
    async fn update_invoice_exp_time(
        &self,
        wallet_id: String,
        invoice_expiration_time: u64,
    ) -> Result<WalletSettingsResponse, Box<dyn std::error::Error>>;
    // Update max channel opening fee [PUT] /wallet/{_version}/wallets/{walletId}/settings/channels/fee
    async fn update_max_opening_fee(
        &self,
        wallet_id: String,
        max_channel_opening_fee: u64,
    ) -> Result<WalletSettingsResponse, Box<dyn std::error::Error>>;
}

impl WalletSettingsRoute for ProtonAPIService {
    async fn update_hide_account(
        &self,
        wallet_id: String,
        hide: HideAccount,
    ) -> Result<WalletSettingsResponse, Box<dyn std::error::Error>> {
        let req =
            HideAccountsReq {
                hide_accounts: hide,
            };

        let path = format!(
            "{}/wallets/{}/settings/accounts/hide",
            self.get_wallet_path(),
            wallet_id
        );
        let res: WalletSettingsResponse = JsonRequest::new(http::Method::PUT, path)
            .body(req)?
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn update_invoice_exp_time(
        &self,
        wallet_id: String,
        invoice_expiration_time: u64,
    ) -> Result<WalletSettingsResponse, Box<dyn std::error::Error>> {
        let path = format!(
            "{}/wallets/{}/settings/invoices/expiration",
            self.get_wallet_path(),
            wallet_id
        );
        let req = InvoiceExpirationTimeReq {
            invoice_expiration_time,
        };
        let res: WalletSettingsResponse = JsonRequest::new(http::Method::PUT, path)
            .body(req)?
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn update_max_opening_fee(
        &self,
        wallet_id: String,
        max_channel_opening_fee: u64,
    ) -> Result<WalletSettingsResponse, Box<dyn std::error::Error>> {
        let path = format!(
            "{}/wallets/{}/settings/channels/fee",
            self.get_wallet_path(),
            wallet_id
        );
        let req = MaxChannelOpeningFeeReq {
            max_channel_opening_fee,
        };
        let res: WalletSettingsResponse = JsonRequest::new(http::Method::PUT, path)
            .body(req)?
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }

    async fn update_invoice_default_desc(
        &self,
        wallet_id: String,
        desc: String,
    ) -> Result<WalletSettingsResponse, Box<dyn std::error::Error>> {
        let req = InvoiceDescriptionReq {
            invoice_default_desc: desc,
        };
        let path = format!(
            "{}/wallets/{}/settings/invoices/description",
            self.get_wallet_path(),
            wallet_id
        );
        let res: WalletSettingsResponse = JsonRequest::new(http::Method::PUT, path)
            .body(req)?
            .bind(self.session_ref())?
            .send()
            .await?
            .body()?;
        Ok(res)
    }
}

#[cfg(test)]
mod test {
    use crate::proton_api::{
        api_service::ProtonAPIService,
        wallet_settings_routes::{HideAccount, WalletSettingsRoute},
    };

    #[tokio::test]
    #[ignore]
    async fn test_update_hide_account() {
        let mut api_service = ProtonAPIService::default();
        api_service.login("feng100", "12345678").await.unwrap();

        let result = api_service
            .update_hide_account("walletID".into(), HideAccount::on)
            .await;
        print!("{:?}", result);
        assert!(result.is_ok());
        let settings_response = result.unwrap();
        assert_eq!(settings_response.code, 1000);
        assert_eq!(settings_response.settings.hide_accounts, 0);
        assert_eq!(
            settings_response.settings.invoice_default_desc.unwrap(),
            "Lightning payment from John Doe."
        );
        assert_eq!(settings_response.settings.invoice_exp_time, 1);
        assert_eq!(settings_response.settings.max_channel_opening_fee, 1);
    }

    #[tokio::test]
    #[ignore]
    async fn test_update_invoice_default_desc() {
        let mut api_service = ProtonAPIService::default();
        api_service.login("feng100", "12345678").await.unwrap();

        let result =
            api_service
                .update_invoice_default_desc(
                    "walletID".into(),
                    "Lightning payment from John Doe.".into(),
                )
                .await;
        print!("{:?}", result);
        assert!(result.is_ok());
        let settings_response = result.unwrap();
        assert_eq!(settings_response.code, 1000);
        assert_eq!(settings_response.settings.hide_accounts, 0);
        assert_eq!(
            settings_response.settings.invoice_default_desc.unwrap(),
            "Lightning payment from John Doe."
        );
        assert_eq!(settings_response.settings.invoice_exp_time, 1);
        assert_eq!(settings_response.settings.max_channel_opening_fee, 1);
    }

    #[tokio::test]
    #[ignore]
    async fn test_update_invoice_exp_time() {
        let mut api_service = ProtonAPIService::default();
        api_service.login("feng100", "12345678").await.unwrap();

        let result = api_service
            .update_invoice_exp_time("walletID".into(), 3600)
            .await;
        print!("{:?}", result);
        assert!(result.is_ok());
        let settings_response = result.unwrap();
        assert_eq!(settings_response.code, 1000);
        assert_eq!(settings_response.settings.hide_accounts, 0);
        assert_eq!(
            settings_response.settings.invoice_default_desc.unwrap(),
            "Lightning payment from John Doe."
        );
        assert_eq!(settings_response.settings.invoice_exp_time, 1);
        assert_eq!(settings_response.settings.max_channel_opening_fee, 1);
    }

    #[tokio::test]
    #[ignore]
    async fn test_update_max_opening_fee() {
        let mut api_service = ProtonAPIService::default();
        api_service.login("feng100", "12345678").await.unwrap();

        let result = api_service
            .update_max_opening_fee("walletID".into(), 5000)
            .await;
        print!("{:?}", result);
        assert!(result.is_ok());
        let settings_response = result.unwrap();
        assert_eq!(settings_response.code, 1000);
        assert_eq!(settings_response.settings.hide_accounts, 0);
        assert_eq!(
            settings_response.settings.invoice_default_desc.unwrap(),
            "Lightning payment from John Doe."
        );
        assert_eq!(settings_response.settings.invoice_exp_time, 1);
        assert_eq!(settings_response.settings.max_channel_opening_fee, 1);
    }
}

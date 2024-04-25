use super::contacts::ProtonContactEmails;
use super::user_settings::ApiUserSettings;
use super::wallet::{ProtonWallet, ProtonWalletKey, WalletTransaction};
use super::wallet_account::WalletAccount;
use super::wallet_settings::WalletSettings;
use andromeda_api::event::{
    ApiContactsEmailEvent, ApiWalletAccountEvent, ApiWalletEvent, ApiWalletKeyEvent,
    ApiWalletSettingsEvent, ApiWalletTransactionsEvent,
};

#[derive(Debug)]
pub struct ProtonEvent {
    pub code: u16,
    pub event_id: String,
    pub refresh: u32,
    pub more: u32,
    pub contact_email_events: Option<Vec<ContactEmailEvent>>,
    pub wallet_events: Option<Vec<WalletEvent>>,
    pub wallet_account_events: Option<Vec<WalletAccountEvent>>,
    pub wallet_key_events: Option<Vec<WalletKeyEvent>>,
    pub wallet_setting_events: Option<Vec<WalletSettingsEvent>>,
    pub wallet_transaction_events: Option<Vec<WalletTransactionEvent>>,
    pub wallet_user_settings: Option<ApiUserSettings>,
}

impl From<andromeda_api::event::ApiProtonEvent> for ProtonEvent {
    fn from(event: andromeda_api::event::ApiProtonEvent) -> Self {
        ProtonEvent {
            code: event.Code,
            event_id: event.EventID,
            refresh: event.Refresh,
            more: event.More,
            contact_email_events: event
                .ContactEmails
                .map(|v| v.into_iter().map(|x| x.into()).collect()),
            wallet_events: event
                .Wallets
                .map(|v| v.into_iter().map(|x| x.into()).collect()),
            wallet_account_events: event
                .WalletAccounts
                .map(|v| v.into_iter().map(|x| x.into()).collect()),
            wallet_key_events: event
                .WalletKeys
                .map(|v| v.into_iter().map(|x| x.into()).collect()),
            wallet_transaction_events: event
                .WalletTransactions
                .map(|v| v.into_iter().map(|x| x.into()).collect()),
            wallet_setting_events: event
                .WalletSettings
                .map(|v| v.into_iter().map(|x| x.into()).collect()),
            wallet_user_settings: event.WalletUserSettings.map(|v| v.into()),
        }
    }
}

#[derive(Debug)]
pub struct WalletEvent {
    pub id: String,
    pub action: u32,
    pub wallet: Option<ProtonWallet>,
}

impl From<ApiWalletEvent> for WalletEvent {
    fn from(event: ApiWalletEvent) -> Self {
        WalletEvent {
            id: event.ID,
            action: event.Action,
            wallet: event.Wallet.map(|x| x.into()),
        }
    }
}

#[derive(Debug)]
pub struct WalletAccountEvent {
    pub id: String,
    pub action: u32,
    pub wallet_account: Option<WalletAccount>,
}

impl From<ApiWalletAccountEvent> for WalletAccountEvent {
    fn from(event: ApiWalletAccountEvent) -> Self {
        WalletAccountEvent {
            id: event.ID,
            action: event.Action,
            wallet_account: event.WalletAccount.map(|x| x.into()),
        }
    }
}

#[derive(Debug)]
pub struct WalletKeyEvent {
    pub id: String,
    pub action: u32,
    pub wallet_key: Option<ProtonWalletKey>,
}

impl From<ApiWalletKeyEvent> for WalletKeyEvent {
    fn from(event: ApiWalletKeyEvent) -> Self {
        WalletKeyEvent {
            id: event.ID,
            action: event.Action,
            wallet_key: event.WalletKey.map(|x| x.into()),
        }
    }
}

#[derive(Debug)]
pub struct WalletSettingsEvent {
    pub id: String,
    pub action: u32,
    pub wallet_settings: Option<WalletSettings>,
}

impl From<ApiWalletSettingsEvent> for WalletSettingsEvent {
    fn from(event: ApiWalletSettingsEvent) -> Self {
        WalletSettingsEvent {
            id: event.ID,
            action: event.Action,
            wallet_settings: event.WalletSettings.map(|x| x.into()),
        }
    }
}

#[derive(Debug)]
pub struct WalletTransactionEvent {
    pub id: String,
    pub action: u32,
    pub wallet_transaction: Option<WalletTransaction>,
}

impl From<ApiWalletTransactionsEvent> for WalletTransactionEvent {
    fn from(event: ApiWalletTransactionsEvent) -> Self {
        WalletTransactionEvent {
            id: event.ID,
            action: event.Action,
            wallet_transaction: event.WalletTransaction.map(|x| x.into()),
        }
    }
}

#[derive(Debug)]
pub struct ContactEmailEvent {
    pub id: String,
    pub action: u32,
    pub contact_email: Option<ProtonContactEmails>,
}

impl From<ApiContactsEmailEvent> for ContactEmailEvent {
    fn from(event: ApiContactsEmailEvent) -> Self {
        ContactEmailEvent {
            id: event.ID,
            action: event.Action,
            contact_email: event.ContactEmail.map(|x| x.into()),
        }
    }
}

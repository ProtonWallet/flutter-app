use super::user_settings::ApiUserSettings;
use super::wallet::{ProtonWallet, ProtonWalletKey};
use super::wallet_account::WalletAccount;
use super::wallet_settings::WalletSettings;
use andromeda_api::event::{
    ApiProtonEvent, ApiWalletAccountEvent, ApiWalletEvent, ApiWalletKeyEvent,
    ApiWalletSettingsEvent,
};

#[derive(Debug)]
pub struct ProtonEvent {
    pub code: u16,
    pub event_id: String,
    pub more: u32,
    pub wallet_events: Option<Vec<WalletEvent>>,
    pub wallet_account_events: Option<Vec<WalletAccountEvent>>,
    pub wallet_key_events: Option<Vec<WalletKeyEvent>>,
    pub wallet_setting_events: Option<Vec<WalletSettingsEvent>>,
    // // pub wallet_transactions: Option<Vec<ApiWalletTransactionsEvent>>,
    pub wallet_user_settings: Option<ApiUserSettings>,
}

impl From<andromeda_api::event::ApiProtonEvent> for ProtonEvent {
    fn from(event: andromeda_api::event::ApiProtonEvent) -> Self {
        ProtonEvent {
            code: event.Code.into(),
            event_id: event.EventID.into(),
            more: event.More.into(),
            wallet_events: event
                .Wallets
                .map(|v| v.into_iter().map(|x| x.into()).collect()),
            wallet_account_events: event
                .WalletAccounts
                .map(|v| v.into_iter().map(|x| x.into()).collect()),
            wallet_key_events: event
                .WalletKeys
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
            id: event.ID.into(),
            action: event.Action.into(),
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
            id: event.ID.into(),
            action: event.Action.into(),
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
            id: event.ID.into(),
            action: event.Action.into(),
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
            id: event.ID.into(),
            action: event.Action.into(),
            wallet_settings: event.WalletSettings.map(|x| x.into()),
        }
    }
}

// #[derive(Debug)]
// pub struct ApiWalletTransactionsEvent {
//     pub id: String,
//     pub action: u32,
//     pub wallet_transaction: Option<WalletTransaction>,
// }

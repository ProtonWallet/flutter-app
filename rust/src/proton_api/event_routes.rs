use super::wallet::WalletTransaction;
use andromeda_api::{
    contacts::ApiContactEmails,
    event::{
        ApiContactsEmailEvent, ApiWalletAccountEvent, ApiWalletEvent, ApiWalletKeyEvent,
        ApiWalletSettingsEvent, ApiWalletTransactionsEvent,
    },
    proton_users::{ProtonUser, ProtonUserSettings},
    settings::UserSettings as ApiWalletUserSettings,
    wallet::{ApiWallet, ApiWalletAccount, ApiWalletKey, ApiWalletSettings},
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
    pub wallet_user_settings: Option<ApiWalletUserSettings>,
    pub proton_user: Option<ProtonUser>,
    pub proton_user_settings: Option<ProtonUserSettings>,
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
            wallet_user_settings: event.WalletUserSettings,
            proton_user: event.User,
            proton_user_settings: event.UserSettings,
        }
    }
}

#[derive(Debug)]
pub struct WalletEvent {
    pub id: String,
    pub action: u32,
    pub wallet: Option<ApiWallet>,
}

impl From<ApiWalletEvent> for WalletEvent {
    fn from(event: ApiWalletEvent) -> Self {
        WalletEvent {
            id: event.ID,
            action: event.Action,
            wallet: event.Wallet,
        }
    }
}

#[derive(Debug)]
pub struct WalletAccountEvent {
    pub id: String,
    pub action: u32,
    pub wallet_account: Option<ApiWalletAccount>,
}

impl From<ApiWalletAccountEvent> for WalletAccountEvent {
    fn from(event: ApiWalletAccountEvent) -> Self {
        WalletAccountEvent {
            id: event.ID,
            action: event.Action,
            wallet_account: event.WalletAccount,
        }
    }
}

#[derive(Debug)]
pub struct WalletKeyEvent {
    pub id: String,
    pub action: u32,
    pub wallet_key: Option<ApiWalletKey>,
}

impl From<ApiWalletKeyEvent> for WalletKeyEvent {
    fn from(event: ApiWalletKeyEvent) -> Self {
        WalletKeyEvent {
            id: event.ID,
            action: event.Action,
            wallet_key: event.WalletKey,
        }
    }
}

#[derive(Debug)]
pub struct WalletSettingsEvent {
    pub id: String,
    pub action: u32,
    pub wallet_settings: Option<ApiWalletSettings>,
}

impl From<ApiWalletSettingsEvent> for WalletSettingsEvent {
    fn from(event: ApiWalletSettingsEvent) -> Self {
        WalletSettingsEvent {
            id: event.ID,
            action: event.Action,
            wallet_settings: event.WalletSettings,
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
    pub contact_email: Option<ApiContactEmails>,
}

impl From<ApiContactsEmailEvent> for ContactEmailEvent {
    fn from(event: ApiContactsEmailEvent) -> Self {
        ContactEmailEvent {
            id: event.ID,
            action: event.Action,
            contact_email: event.ContactEmail,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use andromeda_api::{
        contacts::ApiContactEmails,
        event::{
            ApiContactsEmailEvent, ApiProtonEvent, ApiWalletAccountEvent, ApiWalletEvent,
            ApiWalletKeyEvent, ApiWalletSettingsEvent, ApiWalletTransactionsEvent,
        },
    };

    fn mock_api_proton_event() -> ApiProtonEvent {
        ApiProtonEvent {
            Code: 200,
            EventID: "event_id_123".to_string(),
            Refresh: 0,
            More: 0,
            ContactEmails: Some(vec![ApiContactsEmailEvent {
                ID: "email_event_id".to_string(),
                Action: 1,
                ContactEmail: Some(ApiContactEmails {
                    ID: "email_1".to_string(),
                    Name: "Test Name".to_string(),
                    Email: "test@example.com".to_string(),
                    CanonicalEmail: "test@example.com".to_string(),
                    IsProton: 0,
                }),
            }]),
            Wallets: Some(vec![ApiWalletEvent {
                ID: "wallet_event_id".to_string(),
                Action: 2,
                Wallet: None,
            }]),
            WalletAccounts: Some(vec![ApiWalletAccountEvent {
                ID: "wallet_account_event_id".to_string(),
                Action: 3,
                WalletAccount: None,
            }]),
            WalletKeys: Some(vec![ApiWalletKeyEvent {
                ID: "wallet_key_event_id".to_string(),
                Action: 4,
                WalletKey: None,
            }]),
            WalletSettings: Some(vec![ApiWalletSettingsEvent {
                ID: "wallet_settings_event_id".to_string(),
                Action: 5,
                WalletSettings: None,
            }]),
            WalletTransactions: Some(vec![ApiWalletTransactionsEvent {
                ID: "wallet_txn_event_id".to_string(),
                Action: 6,
                WalletTransaction: None,
            }]),
            WalletUserSettings: None,
            User: None,
            UserSettings: None,
        }
    }

    #[test]
    fn test_proton_event_conversion() {
        let api_event = mock_api_proton_event();
        let proton_event: ProtonEvent = api_event.into();

        assert_eq!(proton_event.code, 200);
        assert_eq!(proton_event.event_id, "event_id_123");
        assert!(proton_event.contact_email_events.is_some());
        assert!(proton_event.wallet_events.is_some());
        assert!(proton_event.wallet_account_events.is_some());
        assert!(proton_event.wallet_key_events.is_some());
        assert!(proton_event.wallet_transaction_events.is_some());
        assert!(proton_event.wallet_setting_events.is_some());
    }

    #[test]
    fn test_wallet_event_conversion() {
        let api_wallet_event = ApiWalletEvent {
            ID: "wallet_event_id".to_string(),
            Action: 2,
            Wallet: None,
        };
        let wallet_event: WalletEvent = api_wallet_event.into();
        assert_eq!(wallet_event.id, "wallet_event_id");
        assert_eq!(wallet_event.action, 2);
        assert!(wallet_event.wallet.is_none());
    }

    #[test]
    fn test_contact_email_event_conversion() {
        let api_contact_event = ApiContactsEmailEvent {
            ID: "email_event_id".to_string(),
            Action: 1,
            ContactEmail: Some(ApiContactEmails {
                ID: "email_1".to_string(),
                Name: "Test Name".to_string(),
                Email: "test@example.com".to_string(),
                CanonicalEmail: "test@example.com".to_string(),
                IsProton: 0,
            }),
        };
        let contact_email_event: ContactEmailEvent = api_contact_event.into();

        assert_eq!(contact_email_event.id, "email_event_id");
        assert_eq!(contact_email_event.action, 1);
        assert!(contact_email_event.contact_email.is_some());
    }
}

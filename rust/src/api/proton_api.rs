pub use andromeda_api::settings::FiatCurrency;
use andromeda_api::{AccessToken, AuthData, ProtonWalletApiClient, RefreshToken, Scope, Uid};
use lazy_static::lazy_static;
use std::sync::{Arc, RwLock};

use crate::proton_api::{
    contacts::ProtonContactEmails,
    errors::ApiError,
    event_routes::ProtonEvent,
    exchange_rate::ProtonExchangeRate,
    proton_address::ProtonAddress,
    user_settings::{ApiUserSettings, CommonBitcoinUnit},
    wallet::{
        BitcoinAddress, CreateWalletReq, EmailIntegrationBitcoinAddress, ProtonWallet,
        WalletBitcoinAddress, WalletData,
    },
    wallet_account::{CreateWalletAccountReq, WalletAccount},
};

lazy_static! {
    static ref PROTON_API: RwLock<Option<Arc<ProtonWalletApiClient>>> = RwLock::new(None);
}

// build functions
pub async fn init_api_service(user_name: String, password: String) {
    // create a global proton api service
    let mut api = ProtonWalletApiClient::from_version(
        "android-wallet@1.0.0-dev".to_string(),
        "ProtonWallet/1.0.0 (Android 12; test; motorola; en)".to_string(),
    );
    api.login(&user_name, &password).await.unwrap();
    let mut api_ref = PROTON_API.write().unwrap();
    *api_ref = Some(Arc::new(api));
}

pub fn init_api_service_from_auth_and_version(
    uid: String,
    access: String,
    refresh: String,
    scopes: Vec<String>,
    app_version: String,
    user_agent: String,
    env: Option<String>,
) {
    // create a global proton api service
    let auth = AuthData::Access(
        Uid::from(uid.clone()),
        RefreshToken::from(refresh.clone()),
        AccessToken::from(access.clone()),
        scopes
            .into_iter()
            .map(|scope_string| Scope::from(scope_string))
            .collect(),
    );
    let api = ProtonWalletApiClient::from_auth_with_version(
        auth,
        app_version.clone(),
        user_agent.clone(),
        env,
    )
    .expect("error from auth()");
    let mut api_ref = PROTON_API.write().unwrap();
    *api_ref = Some(Arc::new(api));
}

// wallets
pub async fn get_wallets() -> Result<Vec<WalletData>, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result: Result<Vec<andromeda_api::wallet::ApiWalletData>, andromeda_api::error::Error> =
        proton_api.wallet.get_wallets().await;
    match result {
        Ok(response) => Ok(response.into_iter().map(|w| w.into()).collect()),
        Err(err) => Err(err.into()),
    }
}

pub async fn create_wallet(wallet_req: CreateWalletReq) -> Result<WalletData, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.wallet.create_wallet(wallet_req.into()).await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn update_wallet_name(
    wallet_id: String,
    new_name: String,
) -> Result<ProtonWallet, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .wallet
        .update_wallet_name(wallet_id, new_name)
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn delete_wallet(wallet_id: String) -> Result<(), ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.wallet.delete_wallet(wallet_id).await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

// wallet accounts
pub async fn get_wallet_accounts(wallet_id: String) -> Result<Vec<WalletAccount>, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.wallet.get_wallet_accounts(wallet_id).await;
    match result {
        Ok(response) => Ok(response.into_iter().map(|a| a.into()).collect()),
        Err(err) => Err(err.into()),
    }
}

pub async fn create_wallet_account(
    wallet_id: String,
    req: CreateWalletAccountReq,
) -> Result<WalletAccount, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .wallet
        .create_wallet_account(wallet_id, req.into())
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn update_wallet_account_label(
    wallet_id: String,
    wallet_account_id: String,
    new_label: String,
) -> Result<WalletAccount, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .wallet
        .update_wallet_account_label(wallet_id, wallet_account_id, new_label)
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn delete_wallet_account(
    wallet_id: String,
    wallet_account_id: String,
) -> Result<(), ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .wallet
        .delete_wallet_account(wallet_id, wallet_account_id)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

pub async fn get_user_settings() -> Result<ApiUserSettings, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.settings.get_user_settings().await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn bitcoin_unit(symbol: CommonBitcoinUnit) -> Result<ApiUserSettings, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.settings.bitcoin_unit(symbol.into()).await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn fiat_currency(symbol: FiatCurrency) -> Result<ApiUserSettings, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.settings.fiat_currency(symbol).await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn two_fa_threshold(amount: u64) -> Result<ApiUserSettings, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.settings.two_fa_threshold(amount).await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn hide_empty_used_addresses(
    hide_empty_used_addresses: bool,
) -> Result<ApiUserSettings, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .settings
        .hide_empty_used_addresses(hide_empty_used_addresses)
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn get_exchange_rate(
    fiat_currency: FiatCurrency,
    time: Option<u64>,
) -> Result<ProtonExchangeRate, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .exchange_rate
        .get_exchange_rate(fiat_currency, time)
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn get_latest_event_id() -> Result<String, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.event.get_latest_event_id().await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

pub async fn collect_events(latest_event_id: String) -> Result<Vec<ProtonEvent>, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.event.collect_events(latest_event_id).await;
    match result {
        Ok(response) => Ok(response.into_iter().map(|x| x.into()).collect()),
        Err(err) => Err(err.into()),
    }
}

pub async fn get_contacts() -> Result<Vec<ProtonContactEmails>, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.contacts.get_contacts(1000, 0).await;
    match result {
        Ok(response) => Ok(response.into_iter().map(|x| x.into()).collect()),
        Err(err) => Err(err.into()),
    }
}

pub async fn get_proton_address() -> Result<Vec<ProtonAddress>, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .proton_email_address
        .get_proton_email_addresses()
        .await;
    match result {
        Ok(response) => Ok(response.into_iter().map(|x| x.into()).collect()),
        Err(err) => Err(err.into()),
    }
}

pub async fn add_email_address(
    wallet_id: String,
    wallet_account_id: String,
    address_id: String,
) -> Result<WalletAccount, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();

    let result = proton_api
        .wallet
        .add_email_address(wallet_id, wallet_account_id, address_id)
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn remove_email_address(
    wallet_id: String,
    wallet_account_id: String,
    address_id: String,
) -> Result<WalletAccount, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();

    let result = proton_api
        .wallet
        .remove_email_address(wallet_id, wallet_account_id, address_id)
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn update_bitcoin_address(
    wallet_id: String,
    wallet_account_id: String,
    wallet_account_bitcoin_address_id: String,
    bitcoin_address: BitcoinAddress,
) -> Result<WalletBitcoinAddress, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();

    let result = proton_api
        .wallet
        .update_bitcoin_address(
            wallet_id,
            wallet_account_id,
            wallet_account_bitcoin_address_id,
            bitcoin_address.into(),
        )
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn add_bitcoin_addresses(
    wallet_id: String,
    wallet_account_id: String,
    bitcoin_addresses: Vec<BitcoinAddress>,
) -> Result<Vec<WalletBitcoinAddress>, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();

    let result = proton_api
        .wallet
        .add_bitcoin_addresses(
            wallet_id,
            wallet_account_id,
            bitcoin_addresses.into_iter().map(|v| v.into()).collect(),
        )
        .await;
    match result {
        Ok(response) => Ok(response.into_iter().map(|x| x.into()).collect()),
        Err(err) => Err(err.into()),
    }
}

pub async fn lookup_bitcoin_address(
    email: String,
) -> Result<EmailIntegrationBitcoinAddress, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();

    let result = proton_api
        .email_integration
        .lookup_bitcoin_address(email)
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn get_wallet_bitcoin_address(
    wallet_id: String,
    wallet_account_id: String,
    only_request: u8,
) -> Result<Vec<WalletBitcoinAddress>, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();

    let result = proton_api
        .wallet
        .get_bitcoin_addresses(wallet_id, wallet_account_id, only_request)
        .await;
    match result {
        Ok(response) => Ok(response.into_iter().map(|v| v.into()).collect()),
        Err(err) => Err(err.into()),
    }
}

pub async fn get_bitcoin_address_latest_index(
    wallet_id: String,
    wallet_account_id: String,
) -> Result<u64, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();

    let result = proton_api
        .wallet
        .get_bitcoin_address_latest_index(wallet_id, wallet_account_id)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

// enable it after 2fa mr ready for andromeda

// pub async fn get_2fa_enabled() -> Result<u32, ApiError> {
//     let proton_api = PROTON_API.read().unwrap().clone().unwrap();
//     let result = proton_api.two_factor_auth.get_2fa_enabled().await;
//     match result {
//         Ok(response) => Ok(response.into()),
//         Err(err) => Err(err.into()),
//     }
// }

// pub async fn set_2fa_totp(
//     username: String,
//     password: String,
//     totp_shared_secret: String,
//     totp_confirmation: String,
// ) -> Result<Vec<String>, ApiError> {
//     let proton_api = PROTON_API.read().unwrap().clone().unwrap();
//     let result = proton_api
//         .two_factor_auth
//         .set_2fa_totp(username, password, totp_shared_secret, totp_confirmation)
//         .await;
//     match result {
//         Ok(response) => Ok(response.into()),
//         Err(err) => Err(err.into()),
//     }
// }

// pub async fn disable_2fa_totp(
//     username: String,
//     password: String,
//     two_factor_code: String,
// ) -> Result<u32, ApiError> {
//     let proton_api = PROTON_API.read().unwrap().clone().unwrap();
//     let result = proton_api
//         .two_factor_auth
//         .disable_2fa_totp(username, password, two_factor_code)
//         .await;
//     match result {
//         Ok(response) => Ok(response.into()),
//         Err(err) => Err(err.into()),
//     }
// }

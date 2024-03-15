use andromeda_api::ProtonWalletApiClient;
use chrono::Utc;
use lazy_static::lazy_static;
use std::sync::{Arc, RwLock};

use crate::proton_api::{
    contacts::ProtonContactEmails,
    errors::ApiError,
    event_routes::ProtonEvent,
    exchange_rate::ProtonExchangeRate,
    user_settings::{ApiFiatCurrency, ApiUserSettings, CommonBitcoinUnit},
    wallet::{CreateWalletReq, ProtonWallet, WalletData},
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

pub async fn fiat_currency(symbol: ApiFiatCurrency) -> Result<ApiUserSettings, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.settings.fiat_currency(symbol.into()).await;
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
    bitcoin_unit: CommonBitcoinUnit,
    fiat_currency: ApiFiatCurrency,
    time: Option<u64>,
) -> Result<ProtonExchangeRate, ApiError> {
    let timestamp = match time {
        Some(t) => t,
        None => Utc::now().timestamp() as u64,
    };
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .exchange_rate
        .get_exchange_rate(bitcoin_unit.into(), fiat_currency.into(), timestamp)
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
        Ok(response) => Ok(response.into()),
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

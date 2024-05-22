pub use andromeda_api::settings::FiatCurrencySymbol as FiatCurrency;
use andromeda_api::{
    transaction::ExchangeRateOrTransactionTime, wallet::CreateWalletTransactionRequestBody,
    AccessToken, AppSpec, AuthData, Product, ProtonWalletApiClient, RefreshToken,
    ReqwestTransportFactory, Scope, Session, Uid,
};
use andromeda_common::BitcoinUnit;
use chrono::Utc;
use lazy_static::lazy_static;
use log::info;
use std::sync::{Arc, RwLock};

use crate::{
    auth_credential::ProtonAuthData,
    auth_store::WalletAuthStore,
    proton_api::{
        contacts::ProtonContactEmails,
        errors::ApiError,
        event_routes::ProtonEvent,
        exchange_rate::ProtonExchangeRate,
        proton_address::{AllKeyAddressKey, ProtonAddress},
        user_settings::ApiUserSettings,
        wallet::{
            BitcoinAddress, CreateWalletReq, EmailIntegrationBitcoinAddress, ProtonWallet,
            WalletBitcoinAddress, WalletData, WalletTransaction,
        },
        wallet_account::{CreateWalletAccountReq, WalletAccount},
    },
};

use crate::bdk::psbt::Transaction;
use bdk::bitcoin::consensus::serialize;
use bdk::bitcoin::Transaction as bdkTransaction;
use bitcoin_internals::hex::display::DisplayHex;

lazy_static! {
    static ref PROTON_API: RwLock<Option<Arc<ProtonWalletApiClient>>> = RwLock::new(None);
}

pub(crate) fn retrieve_proton_api() -> Arc<ProtonWalletApiClient> {
    PROTON_API.read().unwrap().clone().unwrap()
}

// build functions
pub async fn init_api_service(user_name: String, password: String) {
    info!("start init_api_service");
    // create a global proton api service
    let mut api = ProtonWalletApiClient::from_version(
        // TODO:: fix me later add -dev back in debug builds
        "android-wallet@1.0.0".to_string(), //-dev
        "ProtonWallet/1.0.0 (Android 12; test; motorola; en)".to_string(),
    );
    api.login(&user_name, &password).await.unwrap();
    let mut api_ref = PROTON_API.write().unwrap();
    *api_ref = Some(Arc::new(api));
}

// initapiserviceauthstore
pub fn init_api_service_auth_store(
    uid: String,
    access: String,
    refresh: String,
    scopes: Vec<String>,
    app_version: String,
    user_agent: String,
    env: Option<String>,
) {
    info!("start init_api_service");
    info!(
        "uid: {}, access: {}, refresh: {}, scopes: {:?}",
        uid, access, refresh, scopes
    );
    let auth_data = Arc::new(RwLock::new(ProtonAuthData::new(
        uid, refresh, access, scopes,
    )));
    let app_spec = AppSpec::new(Product::Wallet, app_version, user_agent);
    let auth_store_env = env.unwrap_or("atlas".to_string());
    let auth_store = WalletAuthStore::new(auth_store_env, auth_data.clone());
    let transport = ReqwestTransportFactory::new();
    let session = Session::new_with_transport(auth_store, app_spec, transport).unwrap();
    let api = ProtonWalletApiClient::from_session(session);
    let mut api_ref = PROTON_API.write().unwrap();
    *api_ref = Some(Arc::new(api));
}

// initApiServiceFromAuthAndVersion
pub fn init_api_service_from_auth_and_version(
    uid: String,
    access: String,
    refresh: String,
    scopes: Vec<String>,
    app_version: String,
    user_agent: String,
    env: Option<String>,
) {
    info!("start init_api_service with session");
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

pub async fn update_wallet_account_fiat_currency(
    wallet_id: String,
    wallet_account_id: String,
    new_fiat_currency: FiatCurrency,
) -> Result<WalletAccount, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .wallet
        .update_wallet_account_fiat_currency(wallet_id, wallet_account_id, new_fiat_currency)
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

pub async fn bitcoin_unit(symbol: BitcoinUnit) -> Result<ApiUserSettings, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api.settings.bitcoin_unit(symbol).await;
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
    // call_dart_callback("geting_exchange_rate".to_string()).await;
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
        .bitcoin_address
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
        .bitcoin_address
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
    only_request: Option<u8>,
) -> Result<Vec<WalletBitcoinAddress>, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();

    let result = proton_api
        .bitcoin_address
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
        .bitcoin_address
        .get_bitcoin_address_highest_index(wallet_id, wallet_account_id)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

pub async fn get_wallet_transactions(
    wallet_id: String,
    wallet_account_id: Option<String>,
    hashed_txids: Option<Vec<String>>,
) -> Result<Vec<WalletTransaction>, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();

    let result = proton_api
        .wallet
        .get_wallet_transactions(wallet_id, wallet_account_id, hashed_txids)
        .await;
    match result {
        Ok(response) => Ok(response.into_iter().map(|v| v.into()).collect()),
        Err(err) => Err(err.into()),
    }
}

pub async fn create_wallet_transactions(
    wallet_id: String,
    wallet_account_id: String,
    transaction_id: String,
    hashed_transaction_id: String,
    label: Option<String>,
    exchange_rate_id: Option<String>,
    transaction_time: Option<String>,
) -> Result<WalletTransaction, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let payload = CreateWalletTransactionRequestBody {
        TransactionID: transaction_id,
        HashedTransactionID: hashed_transaction_id,
        Label: label,
        ExchangeRateID: exchange_rate_id,
        TransactionTime: transaction_time,
    };
    let result = proton_api
        .wallet
        .create_wallet_transaction(wallet_id, wallet_account_id, payload)
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn update_wallet_transaction_label(
    wallet_id: String,
    wallet_account_id: String,
    wallet_transaction_id: String,
    label: String,
) -> Result<WalletTransaction, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .wallet
        .update_wallet_transaction_label(wallet_id, wallet_account_id, wallet_transaction_id, label)
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

pub async fn delete_wallet_transactions(
    wallet_id: String,
    wallet_account_id: String,
    wallet_transaction_id: String,
) -> Result<(), ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .wallet
        .delete_wallet_transactions(wallet_id, wallet_account_id, wallet_transaction_id)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

pub async fn broadcast_raw_transaction(
    signed_transaction_hex: String,
    wallet_id: String,
    wallet_account_id: String,
    label: Option<String>,
    exchange_rate_id: Option<String>,
    transaction_time: Option<String>,
    address_id: Option<String>,
    subject: Option<String>,
    body: Option<String>,
) -> Result<String, ApiError> {
    let transaction: Transaction = signed_transaction_hex.into();
    let bdk_transaction: &bdkTransaction = &transaction.internal;
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let signed_transaction_hex = serialize(bdk_transaction).to_lower_hex_string();
    println!("signed_transaction_hex: {}", signed_transaction_hex);
    let exchange_rate_or_transaction_time = if let Some(exchange_rate_id) = exchange_rate_id {
        ExchangeRateOrTransactionTime::ExchangeRate(exchange_rate_id)
    } else if let Some(transaction_time) = transaction_time {
        ExchangeRateOrTransactionTime::TransactionTime(transaction_time)
    } else {
        ExchangeRateOrTransactionTime::TransactionTime(Utc::now().timestamp().to_string())
    };
    let result = proton_api
        .transaction
        .broadcast_raw_transaction(
            signed_transaction_hex,
            wallet_id,
            wallet_account_id,
            label,
            exchange_rate_or_transaction_time,
            address_id,
            subject,
            body,
        )
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

pub async fn get_all_public_keys(
    email: String,
    internal_only: u8,
) -> Result<Vec<AllKeyAddressKey>, ApiError> {
    let proton_api = PROTON_API.read().unwrap().clone().unwrap();
    let result = proton_api
        .proton_email_address
        .get_all_public_keys(email, Some(internal_only))
        .await;
    match result {
        Ok(response) => Ok(response.into_iter().map(|v| v.into()).collect()),
        Err(err) => Err(err.into()),
    }
}

pub async fn is_valid_token() -> Result<bool, ApiError> {
    let result = get_latest_event_id().await;
    match result {
        Ok(_) => Ok(true),
        Err(_) => Ok(false),
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

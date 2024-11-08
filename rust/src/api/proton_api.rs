use andromeda_api::{
    bitcoin_address::ApiWalletBitcoinAddress,
    settings::{FiatCurrencySymbol as FiatCurrency, UserSettings as ApiWalletUserSettings},
    wallet::{ApiWallet, ApiWalletAccount, CreateWalletTransactionRequestBody},
    wallet_ext::WalletClientExt,
    ChildSession,
};
use andromeda_common::BitcoinUnit;
use lazy_static::lazy_static;
use log::info;
use std::sync::{Arc, RwLock};

use crate::{
    api::api_service::proton_api_service::ProtonAPIService,
    proton_api::{
        event_routes::ProtonEvent,
        exchange_rate::ProtonExchangeRate,
        proton_address::{AllKeyAddressKey, ProtonAddress},
        wallet::{BitcoinAddress, EmailIntegrationBitcoinAddress, WalletTransaction},
    },
    BridgeError,
};

lazy_static! {
    static ref PROTON_API: RwLock<Option<Arc<ProtonAPIService>>> = RwLock::new(None);
}

/// Retrieve the proton api service cached gloablly
pub(crate) fn retrieve_proton_api() -> Result<Arc<ProtonAPIService>, BridgeError> {
    info!("retrieve_proton_api is called");
    let read_guard = PROTON_API.read()?;
    read_guard.clone().ok_or(BridgeError::ApiLock(
        "PROTON_API api is not set".to_string(),
    ))
}

/// Set the proton api service to be cached globally
pub(crate) fn set_proton_api(inner: Arc<ProtonAPIService>) -> Result<(), BridgeError> {
    info!("set_proton_api is called");
    let mut api_ref = PROTON_API.write()?;
    *api_ref = Some(inner);
    Ok(())
}

/// proton_api.login clear api instance caches
pub(crate) fn logout() -> Result<(), BridgeError> {
    let mut api_ref = PROTON_API.write()?;
    *api_ref = None;
    Ok(())
}

// TODO:: slowly move to use api_service folder functions
/// proton_api.updatewalletname
pub async fn update_wallet_name(
    wallet_id: String,
    new_name: String,
) -> Result<ApiWallet, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api
        .inner
        .clients()
        .wallet
        .update_wallet_name(wallet_id, new_name)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.deletewallet
pub async fn delete_wallet(wallet_id: String) -> Result<(), BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api
        .inner
        .clients()
        .wallet
        .delete_wallet(wallet_id)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.updatewalletaccountlabel
pub async fn update_wallet_account_label(
    wallet_id: String,
    wallet_account_id: String,
    new_label: String,
) -> Result<ApiWalletAccount, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api
        .inner
        .clients()
        .wallet
        .update_wallet_account_label(wallet_id, wallet_account_id, new_label)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.deletewalletaccount
pub async fn delete_wallet_account(
    wallet_id: String,
    wallet_account_id: String,
) -> Result<(), BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api
        .inner
        .clients()
        .wallet
        .delete_wallet_account(wallet_id, wallet_account_id)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.bitcoinunit
pub async fn bitcoin_unit(symbol: BitcoinUnit) -> Result<ApiWalletUserSettings, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api
        .inner
        .clients()
        .settings
        .update_bitcoin_unit(symbol)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.getexchangerate
pub async fn get_exchange_rate(
    fiat_currency: FiatCurrency,
    time: Option<u64>,
) -> Result<ProtonExchangeRate, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api
        .inner
        .clients()
        .exchange_rate
        .get_exchange_rate(fiat_currency, time)
        .await;

    info!("get_exchange_rate: {:?}", result);

    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.getlatesteventid
pub async fn get_latest_event_id() -> Result<String, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api.inner.clients().event.get_latest_event_id().await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.collectevents
pub async fn collect_events(latest_event_id: String) -> Result<Vec<ProtonEvent>, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api
        .inner
        .clients()
        .event
        .collect_events(latest_event_id)
        .await;
    match result {
        Ok(response) => Ok(response.into_iter().map(|x| x.into()).collect()),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.getprotonaddress
pub async fn get_proton_address() -> Result<Vec<ProtonAddress>, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api
        .inner
        .clients()
        .proton_email_address
        .get_proton_email_addresses()
        .await;
    match result {
        Ok(response) => Ok(response.into_iter().map(|x| x.into()).collect()),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.addemailaddress
pub async fn add_email_address(
    wallet_id: String,
    wallet_account_id: String,
    address_id: String,
) -> Result<ApiWalletAccount, BridgeError> {
    let proton_api = retrieve_proton_api()?;

    let result = proton_api
        .inner
        .clients()
        .wallet
        .add_email_address(wallet_id, wallet_account_id, address_id)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.removeemailaddress
pub async fn remove_email_address(
    wallet_id: String,
    wallet_account_id: String,
    address_id: String,
) -> Result<ApiWalletAccount, BridgeError> {
    let proton_api = retrieve_proton_api()?;

    let result = proton_api
        .inner
        .clients()
        .wallet
        .remove_email_address(wallet_id, wallet_account_id, address_id)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.updatebitcoinaddress
pub async fn update_bitcoin_address(
    wallet_id: String,
    wallet_account_id: String,
    wallet_account_bitcoin_address_id: String,
    bitcoin_address: BitcoinAddress,
) -> Result<ApiWalletBitcoinAddress, BridgeError> {
    let proton_api = retrieve_proton_api()?;

    let result = proton_api
        .inner
        .clients()
        .bitcoin_address
        .update_bitcoin_address(
            wallet_id,
            wallet_account_id,
            wallet_account_bitcoin_address_id,
            bitcoin_address.into(),
        )
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.addbitcoinaddresses
pub async fn add_bitcoin_addresses(
    wallet_id: String,
    wallet_account_id: String,
    bitcoin_addresses: Vec<BitcoinAddress>,
) -> Result<Vec<ApiWalletBitcoinAddress>, BridgeError> {
    let proton_api = retrieve_proton_api()?;

    let result = proton_api
        .inner
        .clients()
        .bitcoin_address
        .add_bitcoin_addresses(
            wallet_id,
            wallet_account_id,
            bitcoin_addresses.into_iter().map(|v| v.into()).collect(),
        )
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.lookupbitcoinaddress
pub async fn lookup_bitcoin_address(
    email: String,
) -> Result<EmailIntegrationBitcoinAddress, BridgeError> {
    let proton_api = retrieve_proton_api()?;

    let result = proton_api
        .inner
        .clients()
        .email_integration
        .lookup_bitcoin_address(email)
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.getwalletbitcoinaddress
pub async fn get_wallet_bitcoin_address(
    wallet_id: String,
    wallet_account_id: String,
    only_request: Option<u8>,
) -> Result<Vec<ApiWalletBitcoinAddress>, BridgeError> {
    let proton_api = retrieve_proton_api()?;

    let result = proton_api
        .inner
        .clients()
        .bitcoin_address
        .get_bitcoin_addresses(wallet_id, wallet_account_id, only_request)
        .await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.createwallettransactions
pub async fn create_wallet_transactions(
    wallet_id: String,
    wallet_account_id: String,
    transaction_id: String,
    hashed_transaction_id: String,
    label: Option<String>,
    exchange_rate_id: Option<String>,
    transaction_time: Option<String>,
) -> Result<WalletTransaction, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let payload = CreateWalletTransactionRequestBody {
        TransactionID: transaction_id,
        HashedTransactionID: hashed_transaction_id,
        Label: label,
        ExchangeRateID: exchange_rate_id,
        TransactionTime: transaction_time,
    };
    let result = proton_api
        .inner
        .clients()
        .wallet
        .create_wallet_transaction(wallet_id, wallet_account_id, payload)
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.updatewallettransactionlabel
pub async fn update_wallet_transaction_label(
    wallet_id: String,
    wallet_account_id: String,
    wallet_transaction_id: String,
    label: String,
) -> Result<WalletTransaction, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api
        .inner
        .clients()
        .wallet
        .update_wallet_transaction_label(wallet_id, wallet_account_id, wallet_transaction_id, label)
        .await;
    match result {
        Ok(response) => Ok(response.into()),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.getallpublickeys
pub async fn get_all_public_keys(
    email: String,
    internal_only: u8,
) -> Result<Vec<AllKeyAddressKey>, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api
        .inner
        .clients()
        .proton_email_address
        .get_all_public_keys(email, Some(internal_only))
        .await;
    match result {
        Ok(response) => Ok(response.into_iter().map(|v| v.into()).collect()),
        Err(err) => Err(err.into()),
    }
}

/// proton_api.fork
pub async fn fork() -> Result<ChildSession, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api.inner.fork().await;
    match result {
        Ok(response) => Ok(response),
        Err(err) => Err(err.into()),
    }
}

#[cfg(test)]
mod test {
    use crate::api::{
        api_service::{
            proton_api_service::ProtonAPIService, wallet_auth_store::ProtonWalletAuthStore,
        },
        proton_api::fork,
    };

    #[tokio::test]
    #[ignore]
    async fn test_fork_session() {
        let app_version = "android-wallet@1.0.0".to_string();
        let user_agent = "ProtonWallet/1.0.0 (iOS/17.4; arm64)".to_string();
        let env = "atlas";

        let store = ProtonWalletAuthStore::from_session(
            env,
            "aajxkia2ffiwjsm4gip5g2aahhra2gre".to_string(),
            "ietv5s2jri4hmggjj7bv2dtw6sf3ilp7".to_string(),
            "xwpffga6xbuitqw7sndtya5g2nk5xn4n".to_string(),
            vec![
                "full".to_string(),
                "self".to_string(),
                "payments".to_string(),
                "keys".to_string(),
                "parent".to_string(),
                "user".to_string(),
                "loggedin".to_string(),
                "nondelinquent".to_string(),
                "verified".to_string(),
                "settings".to_string(),
                "wallet".to_string(),
            ],
        )
        .unwrap();
        let mut client =
            ProtonAPIService::new(env.to_string(), app_version, user_agent, store).unwrap();
        client.set_proton_api().unwrap();
        let forked_session = fork().await.unwrap();
        println!("forked session: {:?}", forked_session);
        assert!(!forked_session.access_token.is_empty())
    }

    #[tokio::test]
    #[ignore]
    async fn test_login_fork_session() {
        let app_version = "android-wallet@1.0.0".to_string();
        let user_agent = "ProtonWallet/1.0.0 (iOS/17.4; arm64)".to_string();
        let env = "atlas";

        let user = "test".to_string();
        let pass = "0000".to_string();

        let store = ProtonWalletAuthStore::new(env).unwrap();
        let mut client =
            ProtonAPIService::new(env.to_string(), app_version, user_agent, store).unwrap();
        let auth_info = client.login(user, pass).await.unwrap();
        assert!(!auth_info.access_token.is_empty());
        client.set_proton_api().unwrap();

        let forked_session = fork().await.unwrap();
        println!("forked session: {:?}", forked_session);
        assert!(!forked_session.access_token.is_empty())
    }
}

use andromeda_api::{
    bitcoin_address::ApiWalletBitcoinAddress,
    settings::FiatCurrencySymbol as FiatCurrency,
    wallet::{ApiWalletAccount, CreateWalletTransactionRequestBody},
    wallet_ext::WalletClientExt,
    ChildSession,
};
use lazy_static::lazy_static;
use std::sync::{Arc, RwLock};
use tracing::info;

use crate::{
    api::api_service::proton_api_service::ProtonAPIService,
    proton_api::{
        exchange_rate::ProtonExchangeRate,
        proton_address::ProtonAddress,
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
        .await?;
    Ok(result.into())
}

/// proton_api.getprotonaddress
pub async fn get_proton_address() -> Result<Vec<ProtonAddress>, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    let result = proton_api
        .inner
        .clients()
        .proton_email_address
        .get_proton_email_addresses()
        .await?;
    Ok(result.into_iter().map(|x| x.into()).collect())
}

/// proton_api.addemailaddress
pub async fn add_email_address(
    wallet_id: String,
    wallet_account_id: String,
    address_id: String,
) -> Result<ApiWalletAccount, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    Ok(proton_api
        .inner
        .clients()
        .wallet
        .add_email_address(wallet_id, wallet_account_id, address_id)
        .await?)
}

/// proton_api.updatebitcoinaddress
pub async fn update_bitcoin_address(
    wallet_id: String,
    wallet_account_id: String,
    wallet_account_bitcoin_address_id: String,
    bitcoin_address: BitcoinAddress,
) -> Result<ApiWalletBitcoinAddress, BridgeError> {
    let proton_api = retrieve_proton_api()?;

    Ok(proton_api
        .inner
        .clients()
        .bitcoin_address
        .update_bitcoin_address(
            wallet_id,
            wallet_account_id,
            wallet_account_bitcoin_address_id,
            bitcoin_address.into(),
        )
        .await?)
}

/// proton_api.get_used_indexes
pub async fn get_used_indexes(
    wallet_id: String,
    wallet_account_id: String,
) -> Result<Vec<u64>, BridgeError> {
    let proton_api = retrieve_proton_api()?;

    Ok(proton_api
        .inner
        .clients()
        .bitcoin_address
        .get_used_indexes(wallet_id, wallet_account_id)
        .await?)
}

/// proton_api.addbitcoinaddresses
pub async fn add_bitcoin_addresses(
    wallet_id: String,
    wallet_account_id: String,
    bitcoin_addresses: Vec<BitcoinAddress>,
) -> Result<Vec<ApiWalletBitcoinAddress>, BridgeError> {
    let proton_api = retrieve_proton_api()?;

    Ok(proton_api
        .inner
        .clients()
        .bitcoin_address
        .add_bitcoin_addresses(
            wallet_id,
            wallet_account_id,
            bitcoin_addresses.into_iter().map(|v| v.into()).collect(),
        )
        .await?)
}

/// proton_api.lookupbitcoinaddress
pub async fn lookup_bitcoin_address(
    email: String,
) -> Result<EmailIntegrationBitcoinAddress, BridgeError> {
    let proton_api = retrieve_proton_api()?;

    let response = proton_api
        .inner
        .clients()
        .email_integration
        .lookup_bitcoin_address(email)
        .await?;
    Ok(response.into())
}

/// proton_api.getwalletbitcoinaddress
pub async fn get_wallet_bitcoin_address(
    wallet_id: String,
    wallet_account_id: String,
    only_request: Option<u8>,
) -> Result<Vec<ApiWalletBitcoinAddress>, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    Ok(proton_api
        .inner
        .clients()
        .bitcoin_address
        .get_bitcoin_addresses(wallet_id, wallet_account_id, only_request)
        .await?)
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
    let response = proton_api
        .inner
        .clients()
        .wallet
        .create_wallet_transaction(wallet_id, wallet_account_id, payload)
        .await?;
    Ok(response.into())
}

/// proton_api.fork
pub async fn fork(
    app_version: &str,
    user_agent: &str,
    client_child: &str,
) -> Result<ChildSession, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    Ok(proton_api
        .inner
        .fork(client_child, app_version, user_agent)
        .await?)
}

/// proton_api.fork
pub async fn fork_selector(client_child: &str) -> Result<String, BridgeError> {
    let proton_api = retrieve_proton_api()?;
    Ok(proton_api.inner.fork_selector(client_child).await?)
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
        let app_version = "android-wallet@1.0.0.85-dev".to_string();
        let user_agent = "ProtonWallet/1.0.0 (iOS/17.4; arm64)".to_string();
        let env = "atlas";

        let store = ProtonWalletAuthStore::from_session(
            env,
            "7RVyw4mOd82ePZySf2ONk37jzlMWWxJQxhOZvwgnnGgWJ2naVc_OuRsKv6NVzIyBQf-YmQ2oG6NgbPrX6X38-w==".to_string(),
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
        let mut client = ProtonAPIService::new(
            env.to_string(),
            app_version.clone(),
            user_agent.clone(),
            store,
        )
        .unwrap();
        client.set_proton_api().unwrap();
        let forked_session = fork(&app_version, &user_agent, "ios-wallet").await.unwrap();
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
        let mut client = ProtonAPIService::new(
            env.to_string(),
            app_version.clone(),
            user_agent.clone(),
            store,
        )
        .unwrap();
        let auth_info = client.login(user, pass).await.unwrap();
        assert!(!auth_info.access_token.is_empty());
        client.set_proton_api().unwrap();

        let forked_session = fork(&app_version, &user_agent, "ios-wallet").await.unwrap();
        println!("forked session: {:?}", forked_session);
        assert!(!forked_session.access_token.is_empty())
    }
}

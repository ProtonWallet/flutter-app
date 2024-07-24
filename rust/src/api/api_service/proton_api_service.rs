//proton_api_service.rs
use super::address_client::AddressClient;
use super::discovery_content_client::DiscoveryContentClient;
use super::invite_client::InviteClient;
use super::onramp_gateway_client::OnRampGatewayClient;
use super::price_graph_client::PriceGraphClient;
use super::proton_settings_client::ProtonSettingsClient;
use super::proton_users_client::ProtonUsersClient;
use super::wallet_auth_store::ProtonWalletAuthStore;
use super::{
    bitcoin_address_client::BitcoinAddressClient, block_client::BlockClient,
    email_integration_client::EmailIntegrationClient, event_client::EventClient,
    exchange_rate_client::ExchangeRateClient, proton_contacts_client::ContactsClient,
    proton_email_addr_client::ProtonEmailAddressClient, settings_client::SettingsClient,
    transaction_client::TransactionClient, wallet_client::WalletClient,
};
use crate::api::proton_api::{logout, set_proton_api};
use crate::api::srp::srp_client::SrpClient;
use crate::{auth_credential::AuthCredential, BridgeError};
use andromeda_api::wallet::ApiWalletData;
use andromeda_api::{ApiConfig, Auth, ProtonWalletApiClient, Tokens};
use base64::prelude::BASE64_STANDARD;
use base64::Engine;
use flutter_rust_bridge::frb;
use log::info;
use std::sync::Arc;

#[derive(Clone)]
pub struct ProtonAPIService {
    pub(crate) inner: Arc<andromeda_api::ProtonWalletApiClient>,
    pub(crate) store: Arc<ProtonWalletAuthStore>,
}

impl ProtonAPIService {
    // build functions
    #[frb(sync)]
    pub fn new(
        env: String,
        app_version: String,
        user_agent: String,
        store: ProtonWalletAuthStore,
    ) -> Result<ProtonAPIService, BridgeError> {
        info!(
            "start fresh api client: app version:{} user_agent:{}",
            app_version, user_agent
        );
        let box_store = Box::new(store.clone());
        let config = ApiConfig {
            spec: (app_version, user_agent),
            auth: None,
            url_prefix: None,
            env: Some(env),
            store: Some(box_store),
        };

        let inner_api = ProtonWalletApiClient::from_config(config)?;
        let api: ProtonAPIService = ProtonAPIService {
            inner: Arc::new(inner_api),
            store: Arc::new(store),
        };
        Ok(api)
    }

    pub async fn login(
        &self,
        username: String,
        password: String,
    ) -> Result<AuthCredential, BridgeError> {
        info!("start login ================> ");
        let login_result = self.inner.login(&username, &password).await;
        let user_data = match login_result {
            Ok(res) => Ok(res),
            Err(err) => Err(BridgeError::Generic(err.to_string())),
        }?;
        let user_key = user_data.user.keys.first().unwrap();
        let key_id = user_key.id.clone();
        let encoded_salt = user_data
            .key_salts
            .iter()
            .find(|&key_salt| key_salt.id == key_id)
            .unwrap()
            .key_salt
            .clone()
            .unwrap();

        let raw_salt = BASE64_STANDARD.decode(encoded_salt).unwrap();
        let mailboxpwd = SrpClient::compute_key_password(password.clone(), raw_salt)?;
        let auth = self.store.inner.auth.lock().unwrap().clone();
        let session_id = auth.uid().unwrap().to_string();
        let acc_token = auth.tokens().unwrap().acc_tok().unwrap().to_string();
        let ref_token = auth.ref_tok().unwrap().to_string();
        let scopes = auth.tokens().unwrap().scopes().unwrap();
        info!("session_id: {:?}", session_id);
        Ok(AuthCredential {
            session_id,
            user_id: user_data.user.id,
            access_token: acc_token,
            refresh_token: ref_token,
            event_id: "".to_string(),
            user_mail: user_data.user.email,
            user_name: user_data.user.name.clone(),
            display_name: user_data.user.name.clone(),
            scops: scopes.into(),
            user_key_id: user_key.id.to_string(),
            user_private_key: user_key.private_key.to_string(),
            user_passphrase: mailboxpwd.to_string(),
        })
    }

    pub fn update_auth(
        &mut self,
        uid: String,
        access: String,
        refresh: String,
        scopes: Vec<String>,
    ) -> Result<(), BridgeError> {
        let auth = Auth::internal(uid, Tokens::access(access, refresh, scopes));
        info!("update_auth api service --- loggin");
        let mut old_auth = self.store.inner.auth.lock()?;
        *old_auth = auth;
        info!("auth data is updated");
        Ok(())
    }

    pub fn set_proton_api(&mut self) -> Result<(), BridgeError> {
        set_proton_api(Arc::new(self.clone()))
    }

    pub async fn logout(&mut self) -> Result<(), BridgeError> {
        // self.store.clone().logout().await;
        info!("logout api service is loggin out");
        let mut old_auth = self.store.inner.auth.lock()?;
        *old_auth = Auth::None;
        info!("reset auth data");
        logout()
    }

    /// clients
    pub async fn get_wallets(&self) -> Result<Vec<ApiWalletData>, BridgeError> {
        Ok(self.inner.clients().wallet.get_wallets().await?)
    }

    #[frb(sync)]
    pub fn get_wallet_client(&self) -> WalletClient {
        WalletClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_exchange_rate_client(&self) -> ExchangeRateClient {
        ExchangeRateClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_settings_client(&self) -> SettingsClient {
        SettingsClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_proton_email_addr_client(&self) -> ProtonEmailAddressClient {
        ProtonEmailAddressClient::new(&self)
    }

    //getProtonContactsClient
    #[frb(sync)]
    pub fn get_proton_contacts_client(&self) -> ContactsClient {
        ContactsClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_email_integration_client(&self) -> EmailIntegrationClient {
        EmailIntegrationClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_event_client(&self) -> EventClient {
        EventClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_transaction_client(&self) -> TransactionClient {
        TransactionClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_block_client(&self) -> BlockClient {
        BlockClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_bitcoin_addr_client(&self) -> BitcoinAddressClient {
        BitcoinAddressClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_address_client(&self) -> AddressClient {
        AddressClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_on_ramp_gateway_client(&self) -> OnRampGatewayClient {
        OnRampGatewayClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_invite_client(&self) -> InviteClient {
        InviteClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_price_graph_client(&self) -> PriceGraphClient {
        PriceGraphClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_discovery_content_client(&self) -> DiscoveryContentClient {
        DiscoveryContentClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_proton_user_client(&self) -> ProtonUsersClient {
        ProtonUsersClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_proton_settings_client(&self) -> ProtonSettingsClient {
        ProtonSettingsClient::new(&self)
    }
}

#[cfg(test)]
mod test {

    use crate::{
        api::api_service::{
            proton_api_service::ProtonAPIService, wallet_auth_store::ProtonWalletAuthStore,
        },
        BridgeError,
    };

    #[tokio::test]
    #[ignore]
    async fn test_init_api_and_login() {
        let uid = "c6d5q57l7kiu7rmvz6x3u6c5nx5z6rx2";
        let access_token = "4hswkfyec64s6v735aa2otb5rktjlgyc";
        let refresh_token = "fslfmtvxzvun6djjanqk4cmjxb5425lo";
        let env = "prod";
        let user_agent = "ProtonWallet/1.0.0 (iOS/17.4; arm64)".to_string();
        let app_version = "android-wallet@1.0.0".to_string();
        let store = ProtonWalletAuthStore::new(env).unwrap();

        let mut client =
            ProtonAPIService::new(env.to_string(), app_version, user_agent, store).unwrap();

        client
            .update_auth(
                uid.to_string(),
                access_token.to_string(),
                refresh_token.to_string(),
                vec!["wallet".to_string(), "account".to_string()],
            )
            .unwrap();
        let settings_client = client.get_settings_client();
        let res = settings_client.get_user_settings().await.unwrap();

        println!("{:?}", res);
    }

    #[tokio::test]
    #[ignore]
    async fn test_wallet() -> Result<(), BridgeError> {
        let user = "test";
        let pass = "0000";
        let app_version = "android-wallet@1.0.0".to_string();
        let user_agent = "ProtonWallet/1.0.0 (iOS/17.4; arm64)".to_string();
        let env = "atlas";
        let store = ProtonWalletAuthStore::new(env)?;

        let client =
            ProtonAPIService::new(env.to_string(), app_version, user_agent, store).unwrap();

        let c = client.login(user.to_owned(), pass.to_owned()).await;

        match c {
            Ok(res) => {
                println!("{:?}", res.user_id);
            }
            Err(err) => {
                println!("{:?}", err);
            }
        }
        Ok(())
    }
}

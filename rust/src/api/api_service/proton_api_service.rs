use super::address_client::AddressClient;
use super::wallet_auth_store::ProtonWalletAuthStore;
use super::{
    bitcoin_address_client::BitcoinAddressClient, email_integration_client::EmailIntegrationClient,
    event_client::EventClient, exchange_rate_client::ExchangeRateClient,
    proton_contacts_client::ContactsClient, proton_email_addr_client::ProtonEmailAddressClient,
    settings_client::SettingsClient, transaction_client::TransactionClient,
    wallet_client::WalletClient,
};
use crate::api::proton_api::{logout, set_proton_api};
use crate::{auth_credential::AuthCredential, errors::ApiError};
use andromeda_api::wallet::ApiWalletData;
use andromeda_api::{Auth, ProtonWalletApiClient, Tokens};
use bitcoin::base64::decode;
use flutter_rust_bridge::frb;
use log::info;
use std::str;
use std::sync::{Arc, Mutex};

#[derive(Clone)]
pub struct ProtonAPIService {
    pub inner: Arc<andromeda_api::ProtonWalletApiClient>,
    pub store: Arc<ProtonWalletAuthStore>,
}

impl ProtonAPIService {
    pub fn init_with(
        uid: String,
        access: String,
        refresh: String,
        scopes: Vec<String>,
        app_version: String,
        user_agent: String,
        env: Option<String>,
    ) -> Result<ProtonAPIService, ApiError> {
        info!("start init_api_service");
        info!(
            "uid: {}, access: {}, refresh: {}, scopes: {:?}",
            uid, access, refresh, scopes
        );
        let auth = Arc::new(Mutex::new(Auth::internal(
            uid,
            Tokens::access(access, refresh, scopes),
        )));
        let auth_store_env = env.unwrap_or("atlas".to_string());
        let store = ProtonWalletAuthStore::from_auth(auth_store_env.as_str(), auth)?;

        let api = ProtonWalletApiClient::from_version(app_version, user_agent, store.clone())?;
        Ok(ProtonAPIService {
            inner: Arc::new(api),
            store: Arc::new(store),
        })
    }

    // build functions
    #[frb(sync)]
    pub fn new(store: ProtonWalletAuthStore) -> Result<ProtonAPIService, ApiError> {
        info!("start fresh api client");
        let app_version = "android-wallet@1.0.0";
        let user_agent = "ProtonWallet/1.0.0 (iOS/17.4; arm64)";
        let inner_api = ProtonWalletApiClient::from_version(
            app_version.to_string(),
            user_agent.to_string(),
            store.clone(),
        )?;
        let api: ProtonAPIService = ProtonAPIService {
            inner: Arc::new(inner_api),
            store: Arc::new(store),
        };
        set_proton_api(Arc::new(api.clone()));
        Ok(api)
    }

    pub async fn login(
        &self,
        username: String,
        password: String,
    ) -> Result<AuthCredential, ApiError> {
        info!("start login ================> ");
        let login_result = self.inner.login(username.as_str(), password.as_str()).await;

        let user_data = match login_result {
            Ok(res) => Ok(res),
            Err(err) => Err(ApiError::Generic(err.to_string())),
        }?;

        let user_key = user_data.user.keys.first().unwrap();
        let first_key = user_data.key_salts.first();

        let salt = user_data
            .key_salts
            .first()
            .unwrap()
            .key_salt
            .clone()
            .unwrap();

        let mailbox_pwd =
            proton_srp::mailbox_password_hash(password.as_str(), decode(salt).unwrap().as_slice())?;

        let password: Vec<u8> = mailbox_pwd.as_bytes().to_vec();

        // Define the length of the suffix we want
        let suffix_len = 31;
        // Ensure the vector is long enough
        if password.len() < suffix_len {
            panic!("The password is too short!");
        }
        // Get the last `suffix_len` bytes
        let password_suffix: &[u8] = &password[password.len() - suffix_len..];
        info!("password: {:?}", password);
        let mailboxpwd = str::from_utf8(password_suffix).unwrap();
        info!("mailbox_pwd: {:?}", mailboxpwd);
        info!("user_auth: {:?}", self.store.inner.auth);
        info!("first_key: {:?}", first_key);
        let auth = self.store.inner.auth.lock().unwrap().clone();
        let session_id = auth.uid().unwrap().to_string();
        let acc_token = auth.tokens().unwrap().acc_tok().unwrap().to_string();
        let ref_token = auth.ref_tok().unwrap().to_string();
        let scopes = auth.tokens().unwrap().scopes().unwrap();
        info!("session_id: {:?}", session_id);
        set_proton_api(Arc::new(self.clone()));
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

    pub async fn update_auth(
        &mut self,
        uid: String,
        access: String,
        refresh: String,
        scopes: Vec<String>,
    ) {
        let auth = Auth::internal(uid, Tokens::access(access, refresh, scopes));
        info!("update_auth api service --- loggin");
        let mut old_auth = self.store.inner.auth.lock().unwrap();
        *old_auth = auth;
        info!("auth data is updated");
    }

    pub async fn logout(&mut self) {
        // self.store.clone().logout().await;
        info!("logout api service is loggin out");
        let mut old_auth = self.store.inner.auth.lock().unwrap();
        *old_auth = Auth::None;
        info!("reset auth data");
        logout();
    }

    #[frb(sync)]
    // initapiserviceauthstore
    pub fn init_api_service_auth_store(
        app_version: String,
        user_agent: String,
        store: ProtonWalletAuthStore,
    ) -> Result<ProtonAPIService, ApiError> {
        info!("start init_api_service");
        let inner_api =
            ProtonWalletApiClient::from_version(app_version, user_agent, store.clone())?;
        let api: ProtonAPIService = ProtonAPIService {
            inner: Arc::new(inner_api),
            store: Arc::new(store),
        };
        set_proton_api(Arc::new(api.clone()));
        Ok(api)
    }

    pub async fn get_wallets(&self) -> Result<Vec<ApiWalletData>, ApiError> {
        let result = self.inner.clients().wallet.get_wallets().await;
        match result {
            Ok(response) => Ok(response),
            Err(err) => Err(err.into()),
        }
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
    pub fn get_bitcoin_addr_client(&self) -> BitcoinAddressClient {
        BitcoinAddressClient::new(&self)
    }

    #[frb(sync)]
    pub fn get_address_client(&self) -> AddressClient {
        AddressClient::new(&self)
    }
}

#[cfg(test)]
mod test {
    use andromeda_api::{network::NetworkClient, ProtonUsersClient};

    use crate::{
        api::api_service::{
            proton_api_service::ProtonAPIService, wallet_auth_store::ProtonWalletAuthStore,
        },
        errors::ApiError,
    };

    #[tokio::test]
    #[ignore]
    async fn test_init_api_and_login() {
        let uid = "c6d5q57l7kiu7rmvz6x3u6c5nx5z6rx2";
        let access_token = "4hswkfyec64s6v735aa2otb5rktjlgyc";
        let refresh_token = "fslfmtvxzvun6djjanqk4cmjxb5425lo";
        let store = ProtonWalletAuthStore::new("prod").unwrap();
        let mut client = ProtonAPIService::new(store).unwrap();

        client
            .update_auth(
                uid.to_string(),
                access_token.to_string(),
                refresh_token.to_string(),
                vec!["wallet".to_string(), "account".to_string()],
            )
            .await;

        // let network_client = ProtonUsersClient::new(client.inner.clone());

        // let userinfo = network_client.get_user_settings().await.unwrap();

        let settings_client = client.get_settings_client();
        let res = settings_client.get_user_settings().await.unwrap();

        println!("{:?}", res);
    }

    #[tokio::test]
    async fn test_wallet() -> Result<(), ApiError> {
        let user = "feng200";
        let pass = "12345678";
        let store = ProtonWalletAuthStore::new("prod")?;
        let client = ProtonAPIService::new(store).unwrap();

        let c = client.login(user.to_owned(), pass.to_owned()).await;

        match c {
            Ok(res) => {
                println!("{:?}", res.event_id);
            }
            Err(err) => {
                println!("{:?}", err);
            }
        }
        Ok(())
    }
}

use super::{
    bitcoin_address_client::BitcoinAddressClient, email_integration_client::EmailIntegrationClient,
    event_client::EventClient, exchange_rate_client::ExchangeRateClient,
    proton_contacts_client::ContactsClient, proton_email_addr_client::ProtonEmailAddressClient,
    settings_client::SettingsClient, transaction_client::TransactionClient,
    wallet_client::WalletClient,
};
use crate::{errors::ApiError, wallet::WalletData};
use andromeda_api::{Auth, ProtonWalletApiClient, Tokens};
use flutter_rust_bridge::frb;
use log::info;
use std::sync::Arc;

pub struct ProtonAPIService {
    pub inner: Arc<andromeda_api::ProtonWalletApiClient>,
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

        let auth = Auth::internal(uid, Tokens::access(access, refresh, scopes));
        let api =
            ProtonWalletApiClient::from_auth_with_version(auth, app_version, user_agent, env)?;
        Ok(ProtonAPIService {
            inner: Arc::new(api),
        })
    }
    // initapiserviceauthstore
    // pub fn init_api_service_auth_store(
    //     uid: String,
    //     access: String,
    //     refresh: String,
    //     scopes: Vec<String>,
    //     app_version: String,
    //     user_agent: String,
    //     env: Option<String>,
    // ) {
    //     info!("start init_api_service");
    //     info!(
    //         "uid: {}, access: {}, refresh: {}, scopes: {:?}",
    //         uid, access, refresh, scopes
    //     );
    //     let auth_data = Arc::new(RwLock::new(ProtonAuthData::new(
    //         uid, refresh, access, scopes,
    //     )));
    //     let app_spec = AppSpec::new(Product::Wallet, app_version, user_agent);
    //     let auth_store_env = env.unwrap_or("atlas".to_string());
    //     let auth_store = WalletAuthStore::new(auth_store_env, auth_data.clone());
    //     let transport = ReqwestTransportFactory::new();
    //     let session = Session::new_with_transport(auth_store, app_spec, transport).unwrap();
    //     let api = ProtonWalletApiClient::from_session(session, None);
    //     let mut api_ref = PROTON_API.write().unwrap();
    //     *api_ref = Some(Arc::new(api));
    // }
    // // build functions
    // pub async fn init_api_service(user_name: String, password: String) {
    //     info!("start init_api_service");
    //     // create a global proton api service
    //     let mut api = ProtonWalletApiClient::from_version(
    //         // TODO:: fix me later add -dev back in debug builds
    //         "android-wallet@1.0.0".to_string(), //-dev
    //         "ProtonWallet/1.0.0 (Android 12; test; motorola; en)".to_string(),
    //     );
    //     api.login(&user_name, &password).await.unwrap();
    //     let mut api_ref = PROTON_API.write().unwrap();
    //     *api_ref = Some(Arc::new(api));
    // }

    // // initApiServiceFromAuthAndVersion
    // pub fn init_api_service_from_auth_and_version(
    //     uid: String,
    //     access: String,
    //     refresh: String,
    //     scopes: Vec<String>,
    //     app_version: String,
    //     user_agent: String,
    //     env: Option<String>,
    // ) {
    //     info!("start init_api_service with session");
    //     // create a global proton api service
    //     // let auth = AuthData::Access(
    //     //     Uid::from(uid.clone()),
    //     //     RefreshToken::from(refresh.clone()),
    //     //     AccessToken::from(access.clone()),
    //     //     scopes
    //     //         .into_iter()
    //     //         .map(|scope_string| Scope::from(scope_string))
    //     //         .collect(),
    //     // );

    //     let api = ProtonWalletApiClient::from_auth_with_version(
    //         Auth::None,
    //         app_version.clone(),
    //         user_agent.clone(),
    //         env,
    //     )
    //     .expect("error from auth()");
    //     let mut api_ref = PROTON_API.write().unwrap();
    //     *api_ref = Some(Arc::new(api));
    // }

    // // [initApiService]
    // // build functions
    // pub async fn init_api_service(user_name: String, password: String) {
    //     let auth_data = Arc::new(RwLock::new(ProtonAuthData::new(
    //         "".to_owned(),
    //         "".to_owned(),
    //         "".to_owned(),
    //         vec!["".to_owned()],
    //     )));
    //     // let app_spec = WalletAppSpec::new().inner();
    //     let app_spec = AppSpec::new(
    //         Product::Unspecified,
    //         "android-wallet@1.0.0-dev".to_owned(),
    //         "ProtonWallet/1.0.0 (Android 12; test; motorola; en)".to_owned(),
    //     );
    //     let auth_store = WalletAuthStore::new("atlas:pascal", auth_data.clone());
    //     let mut session = Session::new(auth_store, app_spec).unwrap();
    //     let response = session.authenticate(&user_name, &password).await;
    //     // session.get_auth_uid()
    //     match response {
    //         Ok(_) => {
    //             // store the api service in the global state
    //             // store the user_name and password in the global state
    //             // let auth = auth_store.get_auth();
    //             // auth_store.get_auth();
    //             let uid = session.get_auth_uid().await;

    //             println!("AuthData.UID: {:?}", auth_data.read().unwrap().uid);
    //             println!(
    //                 "AuthData.RefreshToken: {:?}",
    //                 auth_data.read().unwrap().refresh_token
    //             );
    //             println!(
    //                 "AuthData.AccessToken: {:?}",
    //                 auth_data.read().unwrap().access_token
    //             );
    //             println!("AuthData.Scopes: {:?}", auth_data.read().unwrap().scopes);
    //             println!("Authenticated: {:?}", uid);
    //             println!("Authenticated");
    //         }
    //         Err(err) => {
    //             println!("Error: {:?}", err);
    //         }
    //     }
    // }

    pub fn read_text(&self) -> String {
        // self.dir.test()
        "Hello World".to_string()
    }

    pub async fn get_wallets(&self) -> Result<Vec<WalletData>, ApiError> {
        let result = self.inner.clients().wallet.get_wallets().await;
        match result {
            Ok(response) => Ok(response.into_iter().map(|w| w.into()).collect()),
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
}

#[cfg(test)]
mod test {
    // use crate::api::api_service::proton_api_service::ProtonAPIService;

    #[tokio::test]
    #[ignore]
    async fn test_init_api_and_login() {
        // ProtonAPIService::init_api_service("pro".to_owned(), "pro".to_owned())?
    }
}

// pub block: BlockClient,
// pub network: NetworkClient,
// pub address: AddressClient,

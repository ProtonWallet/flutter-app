use std::sync::{Arc, RwLock};

use andromeda_api::{AppSpec, Product, ProtonWalletApiClient, ReqwestTransportFactory, Session};
use log::info;

use crate::{
    auth_store::WalletAuthStore,
    proton_api::{auth_credential::ProtonAuthData, errors::ApiError, wallet::WalletData},
};

// experimental this way look better but need to test out
pub struct ProtonAPIService {
    pub inner: Arc<andromeda_api::ProtonWalletApiClient>,
}

// impl Default for ProtonAPIService {
//     fn default() -> Self {
//         Self::new()
//     }
// }

impl ProtonAPIService {
    // [initWith]
    pub fn init_with(
        uid: String,
        access: String,
        refresh: String,
        scopes: Vec<String>,
        app_version: String,
        user_agent: String,
        env: Option<String>,
    ) -> ProtonAPIService {
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
        ProtonAPIService {
            inner: Arc::new(api),
        }
    }

    // [initApiService]
    // build functions
    pub async fn init_api_service(user_name: String, password: String) {
        let auth_data = Arc::new(RwLock::new(ProtonAuthData::new(
            "".to_owned(),
            "".to_owned(),
            "".to_owned(),
            vec!["".to_owned()],
        )));
        // let app_spec = WalletAppSpec::new().inner();
        let app_spec = AppSpec::new(
            Product::Unspecified,
            "android-wallet@1.0.0-dev".to_owned(),
            "ProtonWallet/1.0.0 (Android 12; test; motorola; en)".to_owned(),
        );
        let auth_store = WalletAuthStore::new("atlas:pascal", auth_data.clone());
        let mut session = Session::new(auth_store, app_spec).unwrap();
        let response = session.authenticate(&user_name, &password).await;
        // session.get_auth_uid()
        match response {
            Ok(_) => {
                // store the api service in the global state
                // store the user_name and password in the global state
                // let auth = auth_store.get_auth();
                // auth_store.get_auth();
                let uid = session.get_auth_uid().await;

                println!("AuthData.UID: {:?}", auth_data.read().unwrap().uid);
                println!(
                    "AuthData.RefreshToken: {:?}",
                    auth_data.read().unwrap().refresh_token
                );
                println!(
                    "AuthData.AccessToken: {:?}",
                    auth_data.read().unwrap().access_token
                );
                println!("AuthData.Scopes: {:?}", auth_data.read().unwrap().scopes);
                println!("Authenticated: {:?}", uid);
                println!("Authenticated");
            }
            Err(err) => {
                println!("Error: {:?}", err);
            }
        }
    }

    pub fn read_text(&self) -> String {
        // self.dir.test()
        "Hello World".to_string()
    }

    pub async fn get_wallets(&self) -> Result<Vec<WalletData>, ApiError> {
        let result = self.inner.wallet.get_wallets().await;
        match result {
            Ok(response) => Ok(response.into_iter().map(|w| w.into()).collect()),
            Err(err) => Err(err.into()),
        }
    }
}

#[cfg(test)]
mod test {
    use crate::api::api_service::proton_api_service::ProtonAPIService;

    #[tokio::test]
    #[ignore]
    async fn test_init_api_and_login() {
        ProtonAPIService::init_api_service("pro".to_owned(), "pro".to_owned()).await;
    }
}

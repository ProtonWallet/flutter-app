use std::sync::{Arc, RwLock};

use flutter_rust_bridge::DartFnFuture;

// pub type DartCallback = dyn Fn(String) -> DartFnFuture<String> + Send + Sync;
// use andromeda_api::{AccessToken, Auth, AuthStore, RefreshToken, Scope, Scopes, Uid};
// use super::auth_credential::ProtonAuthData;
pub type DartCallback = dyn Fn(String, String) -> DartFnFuture<bool> + Send + Sync;
pub struct WalletDataAuthStore {
    env: String,
    // delegate: Arc<DartCallback>,
    // auth: Arc<RwLock<ProtonAuthData>>,
    // auth_temp: Option<Auth>,
}

impl WalletDataAuthStore {
    /// Create a new simple auth store with the given environment name.
    #[must_use]
    pub fn new(
        env: impl Into<String>,
        //delegate: &DartCallback, //, auth: Arc<RwLock<ProtonAuthData>>
    ) -> Self {
        let env = env.into();
        Self {
            env,
            // auth,
            // auth_temp: None,
            // delegate,
        }
    }
}

// impl AuthStore for WalletDataAuthStore {
//     fn get_env_name(&self) -> &str {
//         &self.env
//     }

//     fn get_auth(&self) -> Option<&Auth> {
//         self.auth_temp.as_ref()
//     }

//     /// Set the auth data with single uid, returning it.
//     fn set_uid_auth(&mut self, uid: Uid) -> &Auth {
//         self.auth.write().unwrap().uid = uid.into();

//         self.get_auth().expect("auth is set")
//     }

//     fn set_access_auth(
//         &mut self,
//         uid: Uid,
//         refresh: RefreshToken,
//         access: AccessToken,
//         scopes: Scopes,
//     ) -> &Auth {
//         self.auth.write().unwrap().access_token = access.into();
//         self.auth.write().unwrap().refresh_token = refresh.into();
//         self.auth.write().unwrap().uid = uid.into();
//         self.auth.write().unwrap().scopes = scopes.into_iter().map(|s| s.into()).collect();

//         self.auth_temp = self.auth.read().unwrap().get_auth();

//         self.get_auth().expect("auth is set")
//     }

//     fn set_scopes(&mut self, scopes: Vec<Scope>) -> Option<&Auth> {
//         self.auth.write().unwrap().scopes = scopes.into_iter().map(|s| s.into()).collect();
//         self.get_auth()
//     }

//     fn clear_auth(&mut self) {
//         self.auth_temp = None;
//     }
// }

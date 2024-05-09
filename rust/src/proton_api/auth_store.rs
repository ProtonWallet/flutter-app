use crate::{auth_credential::ProtonAuthData, errors::ApiError};
use andromeda_api::{AccessToken, Auth, AuthStore, RefreshToken, Scope, Scopes, Uid};
use log::{debug, info};
use std::{
    future::Future,
    pin::Pin,
    sync::{Arc, Mutex, RwLock},
};

pub type DartFnFuture<T> = Pin<Box<dyn Future<Output = T> + Send + 'static>>;
pub type DartCallback = dyn Fn(String) -> DartFnFuture<String> + Send + Sync;

lazy_static::lazy_static! {
    static ref GLOBAL_SESSION_UPDATE: Mutex<Option<Arc<DartCallback>>> = Mutex::new(None);
    static ref GLOBAL_SESSION_UPDATE_RUNTIME: RwLock<Option<Arc<tokio::runtime::Runtime>>> = RwLock::new(None);
}

pub(crate) fn set_session_update_delegate(
    callback: impl Fn(String) -> DartFnFuture<String> + Send + Sync + 'static,
) -> Result<(), ApiError> {
    let mut cb = GLOBAL_SESSION_UPDATE.lock().unwrap();
    *cb = Some(Arc::new(callback));

    match tokio::runtime::Builder::new_current_thread().build() {
        Ok(rtime) => {
            let mut rt = GLOBAL_SESSION_UPDATE_RUNTIME.write().unwrap();
            *rt = Some(Arc::new(rtime));
            Ok(())
        }
        Err(e) => Err(ApiError::Generic(format!(
            "Error creating runtime: {:?}",
            e
        ))),
    }
}

pub struct WalletAuthStore {
    env: String,
    auth: Arc<RwLock<ProtonAuthData>>,
    auth_temp: Option<Auth>,
}

impl WalletAuthStore {
    /// Create a new simple auth store with the given environment name.
    #[must_use]
    pub fn new(env: impl Into<String>, auth: Arc<RwLock<ProtonAuthData>>) -> Self {
        let env = env.into();
        let authtemp = auth.read().unwrap().get_auth();
        Self {
            env,
            auth,
            auth_temp: authtemp,
        }
    }
}
pub trait AuthStoreExt {
    fn refresh_auth_credential(&self, message: String);
}

impl AuthStore for WalletAuthStore {
    fn get_env_name(&self) -> &str {
        &self.env
    }

    fn get_auth(&self) -> Option<&Auth> {
        self.auth_temp.as_ref()
    }

    /// Set the auth data with single uid, returning it.
    fn set_uid_auth(&mut self, uid: Uid) -> &Auth {
        self.auth.write().unwrap().uid = uid.into();

        self.get_auth().expect("auth is set")
    }

    fn set_access_auth(
        &mut self,
        uid: Uid,
        refresh: RefreshToken,
        access: AccessToken,
        scopes: Scopes,
    ) -> &Auth {
        info!("set_access_auth");
        self.auth.write().unwrap().access_token = access.into();
        self.auth.write().unwrap().refresh_token = refresh.into();
        self.auth.write().unwrap().uid = uid.into();
        self.auth.write().unwrap().scopes = scopes.into_iter().map(|s| s.into()).collect();

        self.auth_temp = self.auth.read().unwrap().get_auth();

        self.refresh_auth_credential("this is the new access token !!!!!!".to_string());

        self.get_auth().expect("auth is set")
    }

    fn set_scopes(&mut self, scopes: Vec<Scope>) -> Option<&Auth> {
        self.auth.write().unwrap().scopes = scopes.into_iter().map(|s| s.into()).collect();
        self.get_auth()
    }

    fn clear_auth(&mut self) {
        self.auth_temp = None;
    }
}

impl AuthStoreExt for WalletAuthStore {
    fn refresh_auth_credential(&self, message: String) {
        debug!("refresh_auth_credential- start: {}", message);
        let rt = GLOBAL_SESSION_UPDATE_RUNTIME.read().unwrap().clone();
        if let Some(rtime) = rt.as_ref() {
            debug!("refresh_auth_credential found runtime");
            rtime.block_on(async move {
                debug!("refresh_auth_credential run block on");
                let cb = GLOBAL_SESSION_UPDATE.lock().unwrap();
                if let Some(callback) = cb.as_ref() {
                    debug!("refresh_auth_credential found callback and calling it");
                    callback(message).await;
                }
            });
        }
        debug!("refresh_auth_credential- end");
    }
}

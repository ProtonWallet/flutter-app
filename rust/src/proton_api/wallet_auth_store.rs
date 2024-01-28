use muon::AuthAccess;
use muon::{AccessToken, Auth, AuthRefresh, AuthStore, RefreshToken, Scopes, Uid};

enum WalletEnv {
    Prod,
    Atlas,
    AtlasWith(String),
}

#[derive(Debug, Clone)]
pub struct WalletAuthStore {
    env: String, //WalletEnv
    auth: Auth,
}

impl WalletAuthStore { // need link to cache
    #[must_use]
    pub fn new(env: impl Into<String>) -> Self {
        Self {
            env: env.into(),
            auth: Auth::None,
        }
    }
}

impl AuthStore for WalletAuthStore {
    fn get_env_name(&self) -> &String {
        &self.env
    }

    fn get_uid(&self) -> Option<&Uid> {
        match &self.auth {
            Auth::None => None,
            Auth::HasRefreshToken(auth) => Some(&auth.uid),
            Auth::HasAccessToken(auth) => Some(&auth.uid),
        }
    }

    fn get_refresh_token(&self) -> Option<&RefreshToken> {
        match &self.auth {
            Auth::None => None,
            Auth::HasRefreshToken(auth) => Some(&auth.refresh),
            Auth::HasAccessToken(auth) => Some(&auth.refresh),
        }
    }

    fn get_access_token(&self) -> Option<&AccessToken> {
        match &self.auth {
            Auth::HasRefreshToken(_) | Auth::None => None,
            Auth::HasAccessToken(auth) => Some(&auth.access),
        }
    }

    fn get_scopes(&self) -> Option<&Scopes> {
        match &self.auth {
            Auth::HasRefreshToken(_) | Auth::None => None,
            Auth::HasAccessToken(auth) => Some(&auth.scopes),
        }
    }

    fn invalidate_access_token(&mut self) {
        if let Auth::HasAccessToken(auth) = &mut self.auth {
            self.auth = Auth::HasRefreshToken(AuthRefresh {
                uid: auth.uid.clone(),
                refresh: auth.refresh.clone(),
            });
        }
    }

    fn invalidate_session(&mut self) {
        self.auth = Auth::None;
    }

    fn provide_authentication(
        &mut self,
        uid: Uid,
        access: AccessToken,
        refresh: RefreshToken,
        scopes: Scopes,
    ) {
        self.auth =
            Auth::HasAccessToken(AuthAccess {
                uid,
                access,
                refresh,
                scopes,
            });
    }
}

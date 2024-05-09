use andromeda_api::{AccessToken, Auth, AuthData, RefreshToken, Scope, Uid};

pub struct AuthCredential {
    // Session unique ID
    uid: String,
    // user id
    userID: String,
    access_token: String,
    refreshToken: String,
    expiration: i32,
    event_id: String,
}

#[derive(Debug)]
pub struct ProtonAuthData {
    pub uid: String,
    pub refresh_token: String,
    pub access_token: String,
    pub scopes: Vec<String>,
}

impl ProtonAuthData {
    pub fn new(
        uid: String,
        refresh_token: String,
        access_token: String,
        scopes: Vec<String>,
    ) -> Self {
        Self {
            uid,
            refresh_token,
            access_token,
            scopes,
        }
    }

    pub fn get_auth(&self) -> Option<Auth> {
        let uid = self.uid.clone();
        let refresh_token = self.refresh_token.clone();
        let access_token = self.access_token.clone();
        let scopes: Vec<String> = self.scopes.clone();

        let access_auth_data = AuthData::Access(
            Uid::from(uid),
            RefreshToken::from(refresh_token),
            AccessToken::from(access_token),
            scopes.into_iter().map(|x| Scope::from(x)).collect(),
        );
        Some(Auth::init(access_auth_data))
    }
}

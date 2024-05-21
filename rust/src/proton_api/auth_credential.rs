use andromeda_api::{AccessToken, Auth, AuthData, RefreshToken, Scope, Uid};

pub struct AuthCredential {
    // Session unique ID
    uid: String,
    // user id
    user_id: String,
    access_token: String,
    refresh_token: String,
    expiration: i32,
    event_id: String,
}

// "UID": "6f3c4f52cf499c2066e6c5669a293177c1f43755",
// "UserID": "-Bpgivr5H2qGDRiUQ4-7gm5YLf215MEgZCdzOtLW5psxgB8oNc8OnoFRykab4Z23EGEW1ka3GtQPF9xwx9-VUA==",
// "EventID": "ACXDmTaBub14w==",
// "ServerProof": "<base64_encoded_proof>",
// "TokenType": "Bearer",
// "AccessToken": "hnnamrzvsgdbxvx74rjadbovyjy63vz4",
// "RefreshToken": "wfih0367aa7dc0359bf5c42d15a93e6c",
// "ExpiresIn": 360000,
// "LocalID": 0,
// "Scopes": [
// "full"
// ],
// "Scope": "full other_scopes",
// "PasswordMode": 2,
// "TemporaryPassword": 0,
// "2FA": {
// "Enabled": 3,
// "FIDO2": {
// "AuthenticationOptions": { },
// "RegisteredKeys": []
// }
// }
// }

// public var UID: String
//     public var accessToken: String
//     public var refreshToken: String
//     @available(*, deprecated, message: "Please do not use expiration property")
//     public var expiration: Date = .distantPast
//     public var userName: String
//     public var userID: String
//     @available(*, deprecated, renamed: "scopes")
//     public var scope: Scopes { scopes }
//     public var scopes: Scopes

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
            scopes.into_iter().map(Scope::from).collect(),
        );
        Some(Auth::init(access_auth_data))
    }
}

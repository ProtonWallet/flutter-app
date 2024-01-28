use muon::types::auth::AuthInfoRes as MuonAuthInfoRes;
use serde::Deserialize;

#[derive(Debug, Clone)]
pub struct AuthInfo {
    pub code: i64,
    pub modulus: String,
    pub srp_session: String,
    pub salt: String,
    pub server_ephemeral: String,
}

impl From<MuonAuthInfoRes> for AuthInfo {
    fn from(x: MuonAuthInfoRes) -> Self {
        AuthInfo {
            code: x.Code.as_i64().unwrap_or_default(),
            modulus: x.Modulus,
            srp_session: x.SRPSession,
            salt: x.Salt,
            server_ephemeral: x.ServerEphemeral,
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct ResponseCode {
    #[serde(rename(deserialize = "Code"))]
    pub code: i32,
}
use muon::types::auth::AuthInfoRes as MuonAuthInfoRes;

#[derive(Debug, Clone)]
pub struct AuthInfo {
    pub code: i32,
    pub modulus: String,
    pub srp_session: String,
    pub salt: String,
    pub server_ephemeral: String,
}

impl From<MuonAuthInfoRes> for AuthInfo {
    fn from(x: MuonAuthInfoRes) -> Self {
        AuthInfo {
            code: x.Code.as_i64().unwrap_or_default() as i32,
            modulus: x.Modulus,
            srp_session: x.SRPSession,
            salt: x.Salt,
            server_ephemeral: x.ServerEphemeral,
        }
    }
}
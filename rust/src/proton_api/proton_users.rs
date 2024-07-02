use flutter_rust_bridge::frb;

pub use andromeda_api::proton_users::{
    EmptyResponseBody, GetAuthInfoResponseBody, GetAuthModulusResponse, ProtonSrpClientProofs,
    ProtonUser, ProtonUserKey, TwoFA,
};

#[frb(mirror(GetAuthModulusResponse))]
#[allow(non_snake_case)]
pub struct _GetAuthModulusResponse {
    pub Code: u32,
    pub Modulus: String,
    pub ModulusID: String,
}

#[frb(mirror(ProtonUserKey))]
#[allow(non_snake_case)]
pub struct _ProtonUserKey {
    pub ID: String,
    pub Version: u32,
    pub PrivateKey: String,
    pub RecoverySecret: Option<String>,
    pub RecoverySecretSignature: Option<String>,
    pub Token: Option<String>,
    pub Fingerprint: String,
    pub Primary: u32,
    pub Active: u32,
}

#[frb(mirror(ProtonUser))]
#[allow(non_snake_case)]
pub struct _ProtonUser {
    pub ID: String,
    pub Name: String,
    pub UsedSpace: u64,
    pub Currency: String,
    pub Credit: u32,
    pub CreateTime: u64,
    pub MaxSpace: u64,
    pub MaxUpload: u64,
    pub Role: u32,
    pub Private: u32,
    pub Subscribed: u32,
    pub Services: u32,
    pub Delinquent: u32,
    pub OrganizationPrivateKey: Option<String>,
    pub Email: String,
    pub DisplayName: String,
    pub Keys: Option<Vec<ProtonUserKey>>,
    pub MnemonicStatus: u32,
}

#[frb(mirror(TwoFA))]
#[allow(non_snake_case)]
pub struct _TwoFA {
    pub Enabled: u8,
}

#[frb(mirror(GetAuthInfoResponseBody))]
#[allow(non_snake_case)]
pub struct _GetAuthInfoResponseBody {
    pub Code: u32,
    pub Modulus: String,
    pub ServerEphemeral: String,
    pub Version: u8,
    pub Salt: String,
    pub SRPSession: String,
    pub two_fa: TwoFA,
}

#[frb(mirror(ProtonSrpClientProofs))]
#[allow(non_snake_case)]
pub struct _ProtonSrpClientProofs {
    pub ClientEphemeral: String,
    pub ClientProof: String,
    pub SRPSession: String,
    pub TwoFactorCode: Option<String>,
}

#[frb(mirror(EmptyResponseBody))]
#[allow(non_snake_case)]
pub struct _EmptyResponseBody {
    pub Code: u32,
}

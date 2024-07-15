use flutter_rust_bridge::frb;

pub use andromeda_api::{
    proton_settings::{
        ApiMnemonicUserKey, MnemonicAuth, MnemonicUserKey, UpdateMnemonicSettingsRequestBody,
    },
    proton_users::{
        EmailSettings, EmptyResponseBody, FlagsSettings, GetAuthInfoResponseBody,
        GetAuthModulusResponse, HighSecuritySettings, PasswordSettings, PhoneSettings,
        ProtonSrpClientProofs, ProtonUser, ProtonUserKey, ProtonUserSettings, ReferralSettings,
        TwoFA, TwoFASettings,
    },
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

#[frb(mirror(PasswordSettings))]
#[allow(non_snake_case)]
pub struct _PasswordSettings {
    // PasswordSettings is empty here we need it in the parser but we don't use it yet in our implementation
}

#[frb(mirror(PhoneSettings))]
#[allow(non_snake_case)]
pub struct _PhoneSettings {
    // PhoneSettings is empty here we need it in the parser but we don't use it yet in our implementation
}

#[frb(mirror(TwoFASettings))]
#[allow(non_snake_case)]
pub struct _TwoFASettings {
    Enabled: u32,
    Allowed: u32,
}

#[frb(mirror(FlagsSettings))]
#[allow(non_snake_case)]
pub struct _FlagsSettings {
    // FlagsSettings is empty here we need it in the parser but we don't use it yet in our implementation
}

#[frb(mirror(ReferralSettings))]
#[allow(non_snake_case)]
pub struct _ReferralSettings {
    // ReferralSettings is empty here we need it in the parser but we don't use it yet in our implementation
}

#[frb(mirror(EmailSettings))]
#[allow(non_snake_case)]
pub struct _EmailSettings {
    Value: Option<String>,
    Status: u32,
    Notify: u32,
    Reset: u32,
}

#[frb(mirror(HighSecuritySettings))]
#[allow(non_snake_case)]
pub struct _HighSecuritySettings {
    Eligible: u32,
    Value: u32,
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

#[frb(mirror(MnemonicUserKey))]
#[allow(non_snake_case)]
pub struct _MnemonicUserKey {
    pub ID: String,
    pub PrivateKey: String,
}
#[frb(mirror(MnemonicAuth))]
#[allow(non_snake_case)]
pub struct _MnemonicAuth {
    pub Version: u32,
    pub ModulusID: String,
    pub Salt: String,
    pub Verifier: String,
}

#[frb(mirror(UpdateMnemonicSettingsRequestBody))]
#[allow(non_snake_case)]
pub struct _UpdateMnemonicSettingsRequestBody {
    pub MnemonicUserKeys: Vec<MnemonicUserKey>,
    pub MnemonicSalt: String,
    pub MnemonicAuth: MnemonicAuth,
}

#[frb(mirror(ApiMnemonicUserKey))]
#[allow(non_snake_case)]
pub struct _ApiMnemonicUserKey {
    pub ID: String,
    pub PrivateKey: String,
    pub Salt: String,
}

#[frb(mirror(ProtonUserSettings))]
#[allow(non_snake_case)]
pub struct _ProtonUserSettings {
    Email: EmailSettings,
    Password: Option<PasswordSettings>,
    Phone: Option<PhoneSettings>,
    two_fa: Option<TwoFASettings>,
    News: u32,
    Locale: String,
    LogAuth: u32,
    InvoiceText: String,
    Density: u32,
    WeekStart: u32,
    DateFormat: u32,
    TimeFormat: u32,
    Welcome: u32,
    WelcomeFlag: u32,
    EarlyAccess: u32,
    Flags: Option<FlagsSettings>,
    Referral: Option<ReferralSettings>,
    DeviceRecovery: u32,
    Telemetry: u32,
    CrashReports: u32,
    HideSidePanel: u32,
    HighSecurity: HighSecuritySettings,
    SessionAccountRecovery: u32,
}

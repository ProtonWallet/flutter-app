use flutter_rust_bridge::frb;

pub use andromeda_api::{
    proton_settings::{
        ApiMnemonicUserKey, MnemonicAuth, MnemonicUserKey, SetTwoFaTOTPRequestBody,
        SetTwoFaTOTPResponseBody, UpdateMnemonicSettingsRequestBody,
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
    pub Enabled: u32,
    pub Allowed: u32,
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
    pub Value: Option<String>,
    pub Status: u32,
    pub Notify: u32,
    pub Reset: u32,
}

#[frb(mirror(HighSecuritySettings))]
#[allow(non_snake_case)]
pub struct _HighSecuritySettings {
    pub Eligible: u32,
    pub Value: u32,
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
    pub Email: EmailSettings,
    pub Password: Option<PasswordSettings>,
    pub Phone: Option<PhoneSettings>,
    pub two_fa: Option<TwoFASettings>,
    pub News: u32,
    pub Locale: String,
    pub LogAuth: u32,
    pub InvoiceText: String,
    pub Density: u32,
    pub WeekStart: u32,
    pub DateFormat: u32,
    pub TimeFormat: u32,
    pub Welcome: u32,
    pub WelcomeFlag: u32,
    pub EarlyAccess: u32,
    pub Flags: Option<FlagsSettings>,
    pub Referral: Option<ReferralSettings>,
    pub Telemetry: u32,
    pub CrashReports: u32,
    pub HideSidePanel: u32,
    pub HighSecurity: Option<HighSecuritySettings>,
    pub SessionAccountRecovery: u32,
}

#[frb(mirror(SetTwoFaTOTPResponseBody))]
#[allow(non_snake_case)]
pub struct _SetTwoFaTOTPResponseBody {
    pub Code: u32,
    pub TwoFactorRecoveryCodes: Vec<String>,
    pub UserSettings: ProtonUserSettings,
}

#[frb(mirror(SetTwoFaTOTPRequestBody))]
#[allow(non_snake_case)]
pub struct _SetTwoFaTOTPRequestBody {
    pub TOTPConfirmation: String,
    pub TOTPSharedSecret: String,
}

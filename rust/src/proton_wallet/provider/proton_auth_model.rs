use andromeda_api::proton_settings::MnemonicAuth;

#[derive(Debug, Clone, Default)]
pub struct AuthVerifier {
    pub version: u32,
    pub modulus_id: String,
    pub salt: String,
    pub verifier: String,
}

impl From<AuthVerifier> for MnemonicAuth {
    fn from(value: AuthVerifier) -> Self {
        MnemonicAuth {
            Version: value.version,
            ModulusID: value.modulus_id,
            Salt: value.salt,
            Verifier: value.verifier,
        }
    }
}

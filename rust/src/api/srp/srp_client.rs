use std::str::from_utf8;

// srp_client.rs
use flutter_rust_bridge::frb;

use proton_crypto::{
    new_srp_provider,
    srp::{SRPProvider, SRPVerifierB64},
};
use proton_srp::{mailbox_password_hash, SRPAuth, SRPProofB64};

use crate::BridgeError;

pub struct SrpClient {}

impl SrpClient {
    #[frb(sync)]
    pub fn new() -> Self {
        SrpClient {}
    }

    pub fn generate_proofs(
        login_password: String,
        version: u8,
        salt: String,
        modulus: String,
        server_ephemeral: String,
    ) -> Result<SRPProofB64, BridgeError> {
        let client = SRPAuth::new(&login_password, version, &salt, &modulus, &server_ephemeral)?;
        let proofs = client.generate_proofs()?;
        Ok(proofs.into())
    }

    pub fn generate_verifer(
        password: String,
        salt_opt: Option<String>,
        server_modulus: String,
    ) -> Result<SRPVerifierB64, BridgeError> {
        let srp_provider = new_srp_provider();
        let salt: Option<&str> = salt_opt.as_deref();
        let verifier = srp_provider.generate_random_verifer(&password, salt, &server_modulus)?;

        Ok(verifier)
    }

    pub fn compute_key_password(password: String, salt: Vec<u8>) -> Result<String, BridgeError> {
        let hashed_password = mailbox_password_hash(&password, &salt)?;

        let password_raw: Vec<u8> = hashed_password.as_bytes().to_vec();
        let suffix_len = 31;
        // Ensure the vector is long enough
        if password_raw.len() < suffix_len {
            panic!("The password is too short!");
        }
        // Get the last `suffix_len` bytes
        let password_suffix: &[u8] = &password_raw[password_raw.len() - suffix_len..];
        let mailboxpwd = from_utf8(password_suffix)?;
        Ok(mailboxpwd.to_string())
    }
}

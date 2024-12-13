// srp_client.rs
use flutter_rust_bridge::frb;
use proton_crypto::{new_srp_provider, srp::SRPProvider};
use proton_crypto_account::proton_crypto;
use proton_srp::SRPProofB64;

use crate::BridgeError;

pub struct FrbSrpClient {}

impl FrbSrpClient {
    #[frb(sync)]
    pub fn new() -> Self {
        FrbSrpClient {}
    }

    pub fn generate_proofs(
        login_password: String,
        version: u8,
        salt: String,
        modulus: String,
        server_ephemeral: String,
    ) -> Result<SRPProofB64, BridgeError> {
        let srp_provider = new_srp_provider();
        let proofs = srp_provider.generate_client_proof(
            "",
            &login_password,
            version,
            &salt,
            &modulus,
            &server_ephemeral,
        )?;

        Ok(SRPProofB64 {
            client_ephemeral: proofs.ephemeral,
            client_proof: proofs.proof,
            expected_server_proof: proofs.expected_server_proof,
        })
    }
}

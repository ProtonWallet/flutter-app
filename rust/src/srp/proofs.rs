use flutter_rust_bridge::frb;

use proton_crypto_account::proton_crypto;
pub use proton_srp::SRPProofB64;

pub use proton_crypto::srp::ClientVerifier;

#[frb(mirror(SRPProofB64))]
pub struct _SRPProofB64 {
    pub client_ephemeral: String,
    pub client_proof: String,
    pub expected_server_proof: String,
}

#[frb(mirror(ClientVerifier))]
pub struct _ClientVerifier {
    pub version: u8,
    pub salt: String,
    pub verifier: String,
}

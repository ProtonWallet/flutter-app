use flutter_rust_bridge::frb;

pub use proton_srp::SRPProofB64;

pub use proton_crypto::srp::SRPVerifierB64;

#[frb(mirror(SRPProofB64))]
pub struct _SRPProofB64 {
    pub client_ephemeral: String,
    pub client_proof: String,
    pub expected_server_proof: String,
}

#[frb(mirror(SRPVerifierB64))]
pub struct _SRPVerifierB64 {
    pub version: u8,
    pub salt: String,
    pub verifier: String,
}

// srp_client.rs
use flutter_rust_bridge::frb;

use proton_srp::{self, SRPAuth, SRPProofB64};

use crate::BridgeError;

pub struct SrpClient {}

impl SrpClient {
    #[frb(sync)]
    fn new() -> Self {
        SrpClient {}
    }

    fn build_srp_client(
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
}

use proton_crypto::{
    new_srp_provider,
    srp::{ClientVerifier, SRPProvider},
};
use proton_crypto_account::salts::KeySecret;
use proton_srp::{mailbox_password_hash, SRPProofB64};
use std::str::from_utf8;

use super::{errors::WalletCryptoError, Result};

pub struct SrpClient {}
impl SrpClient {
    /// Generates SRP proofs based on the login password, version, salt, modulus, and server ephemeral.
    pub fn generate_proofs(
        login_password: &str,
        version: u8,
        salt: &str,
        modulus: &str,
        server_ephemeral: &str,
    ) -> Result<SRPProofB64> {
        let srp_provider = new_srp_provider();
        let proofs = srp_provider.generate_client_proof(
            "",
            login_password,
            version,
            salt,
            modulus,
            server_ephemeral,
        )?;

        Ok(SRPProofB64 {
            client_ephemeral: proofs.ephemeral,
            client_proof: proofs.proof,
            expected_server_proof: proofs.expected_server_proof,
        })
    }

    /// Generates an SRP verifier based on the password and optional salt.
    pub fn generate_verifier(password: &str, server_modulus: &str) -> Result<ClientVerifier> {
        let srp_provider = new_srp_provider();
        let verifier = srp_provider.generate_client_verifier(password, server_modulus)?;
        Ok(verifier)
    }

    /// Computes the mailbox password hash based on the provided password and salt.
    pub fn compute_key_password(password: &str, salt: Vec<u8>) -> Result<String> {
        let hashed_password = mailbox_password_hash(password, &salt)?;
        let password_raw: Vec<u8> = hashed_password.as_bytes().to_vec();
        let suffix_len = 31;

        if password_raw.len() < suffix_len {
            return Err(WalletCryptoError::SrpPasswordTooShort);
        }

        let password_suffix = &password_raw[password_raw.len() - suffix_len..];
        let mailboxpwd = from_utf8(password_suffix)?;
        Ok(mailboxpwd.to_string())
    }

    pub fn compute_key_password_as_secret(password: &str, salt: Vec<u8>) -> Result<KeySecret> {
        Ok(KeySecret::new(
            Self::compute_key_password(password, salt)?
                .as_bytes()
                .to_vec(),
        ))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::mocks::*;
    use auth::tests::{TEST_MODULUS_CLEAR_SIGN, TEST_SALT, TEST_SERVER_EPHEMERAL};
    use proton_crypto::generate_secure_random_bytes;
    use proton_srp::MailboxHashError;

    #[test]
    fn test_generate_proofs_success() {
        let result =
            SrpClient::generate_proofs("password", 1, "salt", "modulus", "server_ephemeral");
        let error = result.err().unwrap();
        assert!(error
            .to_string()
            .contains("Proton crypto error: Invalid SRP modulus"));
        let result = SrpClient::generate_proofs(
            "password",
            1,
            "salt",
            TEST_MODULUS_CLEAR_SIGN,
            "server_ephemeral",
        );
        let error = result.err().unwrap();
        assert!(error.to_string().contains("Invalid SRP salt: wrong size"));
        let result = SrpClient::generate_proofs(
            "password",
            1,
            TEST_SALT,
            TEST_MODULUS_CLEAR_SIGN,
            "server_ephemeral",
        );
        let error = result.err().unwrap();
        assert!(error
            .to_string()
            .contains("Failed decode base64 encoded parameter"));
        let result = SrpClient::generate_proofs(
            "password",
            5,
            TEST_SALT,
            TEST_MODULUS_CLEAR_SIGN,
            TEST_SERVER_EPHEMERAL,
        );
        let error = result.err().unwrap();
        assert!(error
            .to_string()
            .contains("The SRP protocol version is not supported"));
        let result = SrpClient::generate_proofs(
            "password",
            4,
            TEST_SALT,
            TEST_MODULUS_CLEAR_SIGN,
            TEST_SERVER_EPHEMERAL,
        );
        assert!(result.is_ok())
    }

    #[test]
    fn test_generate_verifier_success() {
        let result = SrpClient::generate_verifier("password", "server_modulus");
        let error = result.err().unwrap();
        assert!(error.to_string().contains("Invalid SRP modulus"));

        let result = SrpClient::generate_verifier("password", TEST_MODULUS_CLEAR_SIGN);
        assert!(result.is_ok());
    }

    #[test]
    fn test_compute_key_password_success() {
        let salt_bytes: [u8; 16] = generate_secure_random_bytes();
        let result = SrpClient::compute_key_password("password", salt_bytes.to_vec());
        println!("{:?}", result);
        assert!(result.is_ok());
        let mailboxpwd = result.unwrap();
        assert_eq!(mailboxpwd.len(), 31); // Expected length of mailbox password suffix
    }

    #[test]
    fn test_compute_key_password_too_short() {
        let salt_bytes: [u8; 2] = generate_secure_random_bytes();
        let result = SrpClient::compute_key_password("shortpassword", salt_bytes.to_vec());
        assert_eq!(
            result.err().unwrap().to_string(),
            WalletCryptoError::MailboxHash(MailboxHashError::InvalidSalt).to_string()
        )
    }
}

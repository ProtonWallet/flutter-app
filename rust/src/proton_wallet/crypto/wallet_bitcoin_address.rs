use core::str;
use proton_crypto::crypto::{UnixTimestamp, Verifier, VerifierSync};
use proton_crypto_account::proton_crypto::crypto::{DataEncoding, PGPProviderSync};

use super::{public_key::PublicKeys, Result};

#[derive(Debug)]
pub struct WalletBTCAddress(Vec<u8>);
impl WalletBTCAddress {
    pub fn new(data: Vec<u8>) -> Self {
        Self(data)
    }

    pub fn new_from_str(plaintext: &str) -> Self {
        Self::new(plaintext.as_bytes().to_vec())
    }
}

impl Default for WalletBTCAddress {
    fn default() -> Self {
        Self::new(Vec::new())
    }
}

impl WalletBTCAddress {
    /// Verifies a PGP signature against the stored wallet address.
    ///
    /// # Parameters
    /// - `provider`: A reference to a `PGPProviderSync` implementation to handle cryptographic operations.
    /// - `pub_keys`: The public keys used for verification.
    /// - `signature`: The detached signature to be verified.
    /// - `context`: The verification context for the operation.
    ///
    /// # Returns
    /// - `Ok(true)` if the signature verification succeeds.
    /// - `Ok(false)` if the verification fails.
    /// - `Err` if an error occurs during verification.
    pub fn verify<Provider: PGPProviderSync>(
        &self,
        provider: &Provider,
        pub_keys: &PublicKeys<Provider>,
        signature: &str,
        context: &str,
    ) -> Result<bool> {
        // Create a verification context with UnixTimestamp set to zero.
        let verification_context =
            provider.new_verification_context(context.to_owned(), true, UnixTimestamp::zero());
        // Perform signature verification using the provider.
        let verification_result = provider
            .new_verifier()
            .with_verification_keys(pub_keys.as_public_keys())
            .with_verification_context(&verification_context)
            .verify_detached(&self.0, signature, DataEncoding::Armor);
        // Return true if verification succeeds, false otherwise.
        Ok(verification_result.is_ok())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::mocks::user_keys::tests::get_test_user_2_locked_proton_address_key;
    use proton_crypto::new_pgp_provider;
    use proton_crypto_account::keys::ArmoredPrivateKey;

    #[test]
    fn test_new_from_str() {
        let plaintext = "test_wallet_bitcoin_id";
        let tx_id = WalletBTCAddress::new_from_str(plaintext);
        assert_eq!(tx_id.0, plaintext.as_bytes());
    }

    #[test]
    fn test_new_from_default() {
        let plaintext = "";
        let tx_id = WalletBTCAddress::default();
        assert_eq!(tx_id.0, plaintext.as_bytes());
    }

    #[test]
    fn test_verify_signature() {
        let signature ="-----BEGIN PGP SIGNATURE-----\n\nwqYEABYKAFgFgmdRW6gJkO9CpuwXvqqMMJSAAAAAABEAFmNvbnRleHRAcHJvdG9u\nLmNod2FsbGV0LmJpdGNvaW4tYWRkcmVzcxYhBKcQ8sEYupYe38hwRu9CpuwXvqqM\nAADv0QEAyvYjLfxMEKDyAnIGxVNjYca1Uw6wkyDZ5LcE6aisd7EA/ipEPdOO2Daz\nYhdvVIalZAi2/pfW58W3K8m6QtTL4b8P\n=4FN8\n-----END PGP SIGNATURE-----\n";
        let message = "你好世界！This is a plaintext message!";
        let context = "wallet.bitcoin-address";
        let addr_key = get_test_user_2_locked_proton_address_key();
        let btc_addr = WalletBTCAddress::new_from_str(message);
        let provider = new_pgp_provider();

        let mut pub_keys = PublicKeys::new();
        pub_keys
            .add_armored_key(&provider, &ArmoredPrivateKey(addr_key.private_key.unwrap()))
            .unwrap();
        let is_ok = btc_addr
            .verify(&provider, &pub_keys, signature, context)
            .unwrap();

        assert!(is_ok);
    }
}

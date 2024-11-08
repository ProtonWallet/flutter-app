use aes_gcm::{
    aead::{Aead, KeyInit},
    AeadCore, Aes256Gcm, Key, Nonce,
};
use andromeda_api::wallet::ApiWalletKey;
use base64::{prelude::BASE64_STANDARD, Engine};
use core::str;
use proton_crypto::crypto::{
    DetachedSignatureVariant, EncryptorDetachedSignatureWriter, UnixTimestamp,
};
use proton_crypto_account::{
    keys::{DecryptedUserKey, UnlockedUserKey},
    proton_crypto::crypto::{
        AsPublicKeyRef, DataEncoding, Decryptor, DecryptorSync, Encryptor, EncryptorSync,
        PGPProviderSync, VerifiedData,
    },
};
use std::io::Write;

use super::{errors::WalletCryptoError, Result};

const SIGNATURE_CONTEXT_WALLET_KEY: &str = "wallet.key";

// UnlockedWalletKey represents a key that can be used to encrypt and decrypt data.
// Wrapped in a tuple struct, it hides its internal representation while still allowing
// certain operations.
#[derive(Clone)]
pub struct UnlockedWalletKey(pub(crate) Key<Aes256Gcm>);

impl UnlockedWalletKey {
    pub fn new(bytes: &[u8]) -> Self {
        let key: Key<Aes256Gcm> = *Key::<Aes256Gcm>::from_slice(bytes);
        UnlockedWalletKey(key)
    }

    /// Locks the wallet, returning a `LockedWalletKey`.
    ///
    /// This method encrypts the wallet data using the provided unlocked private keys,
    /// and attaches a detached signature for integrity verification.
    ///
    /// # Parameters:
    /// - `provider`: The cryptographic provider that supplies encryption and signing capabilities (e.g., PGP).
    /// - `user_key`: The unlocked user key, which provides both the public key for encryption and the private key for signing.
    ///
    /// # Returns:
    /// - `Ok(LockedWalletKey)`: On success, returns the encrypted wallet data and its associated detached signature.
    /// - `Err(WalletCryptoError)`: If any error occurs during encryption or signing, it returns a `WalletCryptoError`.
    pub fn lock_with<T: PGPProviderSync>(
        &self,
        provider: &T,
        user_key: &UnlockedUserKey<T>,
    ) -> Result<LockedWalletKey> {
        // Buffer to store encrypted data
        let mut result_data: Vec<u8> = Vec::new();
        let signing_context =
            provider.new_signing_context(SIGNATURE_CONTEXT_WALLET_KEY.to_owned(), true);
        // Create an encryptor using the public key for encryption and private key for signing.
        let mut encryptor_writer = provider
            .new_encryptor()
            .with_encryption_key(user_key.as_public_key()) // Encrypt with the public key
            .with_signing_key(user_key.as_ref()) // Sign with the private key
            .with_signing_context(&signing_context)
            .encrypt_stream_with_detached_signature(
                // Output the encrypted data here
                &mut result_data,
                // Signature format for the encrypted data
                DetachedSignatureVariant::Plaintext,
                DataEncoding::Armor,
            )?;

        // Write the raw wallet data into the encryption stream.
        encryptor_writer.write_all(self.as_bytes())?;

        // Finalize the encryption process and retrieve the detached signature.
        let detached_signature = encryptor_writer.finalize_with_detached_signature()?;

        // Convert both the encrypted data and the detached signature to UTF-8 strings.
        let encrypted = str::from_utf8(&result_data)?; // Convert encrypted bytes to string
        let signature = str::from_utf8(&detached_signature)?; // Convert signature bytes to string

        // Return the locked wallet as a `LockedWalletKey`, containing both the encrypted data and its signature.
        Ok(LockedWalletKey::new(
            encrypted.to_string(),
            signature.to_string(),
        ))
    }

    // Converts the key to a Base64 encoded string.
    pub fn to_base64(&self) -> String {
        BASE64_STANDARD.encode(self.0)
    }

    // Returns the key as a vector of bytes.
    pub fn to_entropy(&self) -> Vec<u8> {
        self.as_bytes().to_vec()
    }

    fn as_bytes(&self) -> &[u8] {
        self.0.as_slice()
    }

    // Initializes the AES-GCM cipher with the secret key.
    fn get_cipher(&self) -> Aes256Gcm {
        Aes256Gcm::new(&self.0)
    }
}

impl UnlockedWalletKey {
    /// Decrypts the provided encrypted data using AES-GCM with the unlocked wallet key.
    ///
    /// This function takes in a byte slice that represents encrypted data,
    /// decrypts it using the AES-GCM algorithm, and returns the original plaintext.
    /// The encrypted data must include a 12-byte IV (Initialization Vector) followed by the ciphertext.
    ///
    /// # How it Works
    /// - First, we check that the input data is large enough to contain the necessary IV.
    /// - Then, we extract the IV from the first 12 bytes—think of it as the "key" that unlocks the rest.
    /// - The rest of the input data is the actual ciphertext that needs to be decrypted.
    /// - We initialize the AES-GCM cipher with the secret key, use the IV, and finally decrypt the ciphertext.
    ///
    /// # Errors
    /// - Returns [`WalletCryptoError::InvalidDataSize`] if the input is too short to contain an IV.
    /// - Returns [`WalletCryptoError::DecryptionFailed`] if the decryption process fails, which might happen if the ciphertext is corrupted or the key/IV is incorrect.
    ///
    /// # Parameters
    /// - `encrypted_bytes`: A byte slice containing the encrypted data, structured as `12-byte IV | ciphertext`.
    ///
    /// # Returns
    /// - `Ok(Vec<u8>)`: On success, returns the original plaintext as a vector of bytes.
    /// - `Err(WalletCryptoError)`: On failure, returns an error indicating what went wrong during decryption.
    ///
    pub fn decrypt(&self, encrypted_bytes: &[u8]) -> Result<Vec<u8>> {
        // Ensure the encrypted data is large enough to contain an IV (12 bytes).
        if encrypted_bytes.len() < 12 {
            // The encrypted data is too small. Something's fishy!
            return Err(WalletCryptoError::InvalidDataSize);
        }

        // Extract the IV (first 12 bytes)
        let iv = Nonce::from_slice(&encrypted_bytes[0..12]);

        // Extract the ciphertext (bytes between the IV and MAC)
        let ciphertext = &encrypted_bytes[12..];

        // Initialize the AES-GCM cipher with the secret key
        let cipher = self.get_cipher();

        let decrypted_bytes = cipher.decrypt(iv, ciphertext.as_ref())?;
        Ok(decrypted_bytes)
    }

    /// Encrypts the provided plaintext data using AES-GCM with the unlocked wallet key.
    ///
    /// This function takes in a byte slice of plaintext, encrypts it using the AES-GCM algorithm,
    /// and returns the encrypted data. A random IV (Initialization Vector) is generated for each encryption
    /// to ensure that even identical plaintexts result in different ciphertexts. The output is a
    /// concatenation of the IV and the ciphertext.
    ///
    /// # How it Works
    /// - First, we generate a random IV using a secure random number generator. This ensures uniqueness for each encryption operation.
    /// - We then initialize the AES-GCM cipher with the secret key and use it to encrypt the plaintext.
    /// - The resulting ciphertext includes a Message Authentication Code (MAC) to ensure the integrity of the data.
    /// - Finally, we concatenate the IV and the ciphertext, and return this secure package as the output.
    ///
    /// # Errors
    /// - Returns [`WalletCryptoError::EncryptionFailed`] if the encryption process fails due to any internal errors within the cryptographic library or invalid input data.
    ///
    /// # Parameters
    /// - `clear_bytes`: A byte slice containing the plaintext data that you want to encrypt.
    ///
    /// # Returns
    /// - `Ok(Vec<u8>)`: On success, returns a vector of bytes containing the concatenated IV and ciphertext.
    /// - `Err(WalletCryptoError)`: On failure, returns an error indicating what went wrong during encryption.
    pub fn encrypt(&self, clear_bytes: &[u8]) -> Result<Vec<u8>> {
        // get the cipher
        let cipher = self.get_cipher();
        // Generate a random nonce (IV)
        let iv = &Aes256Gcm::generate_nonce(&mut rand::rngs::OsRng);
        // Encrypt the plaintext, ciphertext includes the mac(tag)
        let ciphertext = cipher.encrypt(iv, clear_bytes)?;
        // Concatenate IV and ciphertext into a single vector
        let encrypted_data = [iv.as_slice(), ciphertext.as_slice()].concat();
        // Return the combined IV and ciphertext
        Ok(encrypted_data)
    }

    // #[allow(dead_code)]
    // fn encrypt_with_associated_data(
    //     &self,
    //     _associated_data: &[u8],
    //     _clear_bytes: &[u8],
    // ) -> Result<Vec<u8>> {
    //     unimplemented!("This function is not implemented yet. place holder for future")
    // }
}

// armored wallet key
pub struct LockedWalletKey {
    pub(crate) encrypted: String,
    pub(crate) signature: String,
}

impl From<ApiWalletKey> for LockedWalletKey {
    fn from(api_wallet_key: ApiWalletKey) -> LockedWalletKey {
        LockedWalletKey::new(api_wallet_key.WalletKey, api_wallet_key.WalletKeySignature)
    }
}

impl LockedWalletKey {
    pub fn new(armored: String, signature: String) -> Self {
        LockedWalletKey {
            encrypted: armored,
            signature,
        }
    }

    pub fn get_armored(&self) -> String {
        self.encrypted.clone()
    }

    pub fn get_signature(&self) -> String {
        self.signature.clone()
    }
}
impl LockedWalletKey {
    /// Unlocks the encrypted wallet key using the provided decryption keys.
    ///
    /// This method verifies the integrity of the encrypted wallet data using the detached signature
    /// and decrypts it using the provided `user_keys`.
    ///
    /// # Parameters:
    /// - `provider`: The cryptographic provider that will handle decryption and signature verification.
    /// - `user_keys`: The decrypted user keys that will be used to decrypt the encrypted wallet data.
    ///    This is passed as a reference to an array of decrypted keys.
    ///
    /// # Returns:
    /// - `Ok(UnlockedWalletKey)`: On success, returns the decrypted wallet key.
    /// - `Err(WalletCryptoError)`: If any step of decryption or verification fails, returns an error.
    ///
    /// # Notes: must try all user keys to unlock the wallet key
    pub fn unlock_with<T: PGPProviderSync>(
        &self,
        provider: &T,
        user_keys: impl AsRef<[DecryptedUserKey<T::PrivateKey, T::PublicKey>]>,
    ) -> Result<UnlockedWalletKey> {
        let verification_context = provider.new_verification_context(
            SIGNATURE_CONTEXT_WALLET_KEY.to_owned(),
            true,
            UnixTimestamp::zero(),
        );

        let decrypted_result = provider
            .new_decryptor()
            // Use the provided user keys for decryption
            .with_decryption_key_refs(user_keys.as_ref())
            // Use the same keys for signature verification
            .with_verification_key_refs(user_keys.as_ref())
            // Attach the detached signature to verify
            // The signature is in Armor encoding and must be checked for integrity (true).
            .with_detached_signature_ref(
                // Signature data to verify
                self.signature.as_bytes(),
                DetachedSignatureVariant::Plaintext,
                true,
            )
            .with_verification_context(&verification_context)
            // Decrypt the encrypted wallet data.
            .decrypt(&self.encrypted, DataEncoding::Armor)?;

        // Verify that the decryption was successful and that the signature was valid.
        // This will throw an error if the signature verification failed.
        decrypted_result.verification_result()?;

        let bytes = decrypted_result.as_bytes();
        Ok(UnlockedWalletKey::new(bytes))
    }
}

#[cfg(test)]
mod test {
    use crate::{
        mocks::user_keys::tests::{
            get_test_user_2_locked_user_key, get_test_user_2_locked_user_key_secret,
            get_test_user_3_locked_user_key, get_test_user_3_locked_user_key_secret,
        },
        proton_wallet::crypto::{
            errors::WalletCryptoError,
            mnemonic::{EncryptedWalletMnemonic, WalletMnemonic},
            private_key::LockedPrivateKeys,
            wallet_key::LockedWalletKey,
            wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
        },
    };
    use aes_gcm::{aead::Aead, AeadCore, Aes256Gcm};
    use proton_crypto::new_pgp_provider;
    use secrecy::ExposeSecret;

    #[test]
    fn test_wallet_key() {
        let wallet_key = WalletKeyProvider::generate();
        let key_bytes: &[u8] = wallet_key.as_bytes();
        let size = wallet_key.0.len();
        assert!(key_bytes.len() == size);
        assert!(key_bytes.len() == 32);
        let cipher = wallet_key.get_cipher();
        let nonce = Aes256Gcm::generate_nonce(&mut rand::rngs::OsRng);
        let ciphertext = cipher
            .encrypt(&nonce, b"plaintext message".as_ref())
            .unwrap();
        let plaintext = cipher.decrypt(&nonce, ciphertext.as_ref()).unwrap();
        assert_eq!(&plaintext, b"plaintext message");
    }

    #[test]
    fn test_wallet_key_restore() {
        let key_bytes: [u8; 32] = [
            109, 28, 56, 47, 162, 59, 15, 201, 117, 153, 43, 109, 252, 24, 218, 93, 13, 147, 235,
            86, 74, 233, 105, 58, 246, 122, 231, 97, 212, 118, 239, 154,
        ];

        let wallet_key = WalletKeyProvider::restore(&key_bytes).unwrap();
        assert_eq!(wallet_key.to_entropy(), key_bytes);
        let cipher = wallet_key.get_cipher();
        let nonce = Aes256Gcm::generate_nonce(&mut rand::rngs::OsRng);
        let ciphertext = cipher
            .encrypt(&nonce, b"plaintext message".as_ref())
            .unwrap();
        let plaintext = cipher.decrypt(&nonce, ciphertext.as_ref()).unwrap();
        assert_eq!(&plaintext, b"plaintext message");
    }

    #[test]
    fn test_wallet_key_restore_base64() {
        let wallet_key =
            WalletKeyProvider::restore_base64("MmI0OGRmZjQ2YzNhN2YyYmQ2NjFlNWEzNzljYTQwZGQ=")
                .unwrap();
        let cipher = wallet_key.get_cipher();
        let nonce = Aes256Gcm::generate_nonce(&mut rand::rngs::OsRng);
        let ciphertext = cipher
            .encrypt(&nonce, b"plaintext message".as_ref())
            .unwrap();
        let plaintext = cipher.decrypt(&nonce, ciphertext.as_ref()).unwrap();
        assert_eq!(&plaintext, b"plaintext message");
    }
    #[test]
    fn test_decryption() {
        let plain_text: &str = "Hello AES-256-GCM";
        let encrypt_text = "dTb2Z1bsWkpo2TTCWOK09tanO3n5Ipepbj5WlCRZSuvlkEAxfePeUBCu4Qo6";
        let base64_key = "MmI0OGRmZjQ2YzNhN2YyYmQ2NjFlNWEzNzljYTQwZGQ=";
        let wallet_key = WalletKeyProvider::restore_base64(base64_key).unwrap();
        let encrypted_body = EncryptedWalletMnemonic::new_from_base64(encrypt_text).unwrap();
        let clean_text = encrypted_body.decrypt_with(&wallet_key).unwrap();

        assert_eq!(
            clean_text.as_utf8_string().unwrap().expose_secret(),
            plain_text
        );

        let bad_byte_key = [
            239, 203, 93, 93, 253, 145, 0, 82, 0, 145, 154, 177, 206, 86, 83, 32, 251, 160, 160,
            29, 164, 144, 177, 0, 205, 128, 0, 38, 59, 33, 146, 218,
        ];
        let wallet_key = WalletKeyProvider::restore(&bad_byte_key).unwrap();
        let error = encrypted_body.decrypt_with(&wallet_key).err();
        assert!(error.is_some());
        match error {
            Some(WalletCryptoError::AesGcm(msg)) => {
                assert!(!msg.is_empty());
            }
            _ => panic!("Expected WalletCryptoError::AesGcm variant"),
        }

        let bad_encrypted_data = [239, 203, 93, 93, 253, 145, 0];
        let encrypted_body = EncryptedWalletMnemonic::new(bad_encrypted_data.to_vec());
        let error = encrypted_body.decrypt_with(&wallet_key).err();
        assert!(error.is_some());
        match error {
            Some(WalletCryptoError::InvalidDataSize) => {}
            _ => panic!("Expected (WalletCryptoError::InvalidDataSize"),
        }
    }

    #[test]
    fn test_generate_and_restore_wallet_key() {
        let wallet_key = WalletKeyProvider::generate();
        let encoded_entropy = wallet_key.to_base64();
        let plain_text = "Hello world";
        let plant_body = WalletMnemonic::new_from_str(plain_text);
        let encrypted_body = plant_body.encrypt_with(&wallet_key).unwrap();
        let check_wallet_key = WalletKeyProvider::restore_base64(&encoded_entropy).unwrap();
        let decrypted_body = encrypted_body.decrypt_with(&check_wallet_key).unwrap();
        assert_eq!(
            decrypted_body.as_utf8_string().unwrap().expose_secret(),
            plain_text
        );
    }

    #[test]
    fn test_restore_wallet_key_and_encrypt() {
        let plaintext = "benefit indoor helmet wine exist height grain spot rely half beef nothing";
        let byte_key = [
            239, 203, 93, 93, 253, 145, 50, 82, 227, 145, 154, 177, 206, 86, 83, 32, 251, 160, 160,
            29, 164, 144, 177, 101, 205, 128, 169, 38, 59, 33, 146, 218,
        ];
        let wallet_key = WalletKeyProvider::restore(&byte_key).unwrap();

        let plant_body = WalletMnemonic::new_from_str(plaintext);
        let encrypted_body = plant_body.encrypt_with(&wallet_key).unwrap();

        let clear_text_boidy = encrypted_body.decrypt_with(&wallet_key).unwrap();
        assert!(clear_text_boidy.as_utf8_string().unwrap().expose_secret() == plaintext);
    }

    #[test]
    fn test_lock_wallet_key() {
        let byte_key = [
            239, 203, 93, 93, 253, 145, 50, 82, 227, 145, 154, 177, 206, 86, 83, 32, 251, 160, 160,
            29, 164, 144, 177, 101, 205, 128, 169, 38, 59, 33, 146, 218,
        ];
        let wallet_key = WalletKeyProvider::restore(&byte_key).unwrap();

        // user key to lock the wallet
        let provider = new_pgp_provider();
        let locked_user_key = get_test_user_2_locked_user_key();
        let key_secret = get_test_user_2_locked_user_key_secret();
        let locked_keys = LockedPrivateKeys::from_primary(locked_user_key);
        let unlocked_user_keys = locked_keys.unlock_with(&provider, &key_secret);
        assert!(!unlocked_user_keys.user_keys.is_empty());
        let locked_wallet_key = wallet_key
            .lock_with(&provider, unlocked_user_keys.user_keys.first().unwrap())
            .unwrap();
        let armored_message = locked_wallet_key.get_armored();
        assert!(!armored_message.is_empty());
        let armored_signature = locked_wallet_key.get_signature();
        assert!(!armored_signature.is_empty());
    }

    #[test]
    fn test_unlock_wallet_key() {
        let byte_key = [
            239, 203, 93, 93, 253, 145, 50, 82, 227, 145, 154, 177, 206, 86, 83, 32, 251, 160, 160,
            29, 164, 144, 177, 101, 205, 128, 169, 38, 59, 33, 146, 218,
        ];
        // restore the wallet key
        let armored_encrypted_message = "-----BEGIN PGP MESSAGE-----\n\nwV4DcsIsGT18EWcSAQdA470+uQXoFiWdZpCsAEgbMdjJRCjMqszNbtJQzvszrWEw\na/SJbREBGGix0byD0wz1OXHCDHHDuk42xpaXdK+16Q8aL3qYdDvL3o2foUTkR+sQ\n0lEB8m4dH4rLSeb/XPO3vFrFWhNTo6HEqsi2LDjxc+Ht3ZxZSsl0ajFDgr2OV+O1\nnNq7hTKrnwMd1DknxUcykvvLzwnVgPPKTKeivJboCQChpOc=\n=Po8E\n-----END PGP MESSAGE-----\n";
        let armored_signature = "-----BEGIN PGP SIGNATURE-----\n\nwpoEABYKAEwFgmbkEEwJkP3x66xOhANrJJSAAAAAABEACmNvbnRleHRAcHJvdG9u\nLmNod2FsbGV0LmtleRYhBMZ9T6whFVji9dBihP3x66xOhANrAAD3AgD/XVthoS2S\nWiXUH1HpBgwDiWEl9vn/GQgp61wOMdZfdrQBAMPVbxEsjW/RYjEM/IkuIa7rejjT\n5Q+kRnd0wuAtJDsG\n=BNBE\n-----END PGP SIGNATURE-----\n";
        let locked_wallet_key = LockedWalletKey::new(
            armored_encrypted_message.to_string(),
            armored_signature.to_string(),
        );

        // user key to lock the wallet
        let provider = new_pgp_provider();
        let locked_user_key = get_test_user_2_locked_user_key();
        let key_secret = get_test_user_2_locked_user_key_secret();

        let locked_keys = LockedPrivateKeys::from_primary(locked_user_key);
        let unlocked_user_keys = locked_keys.unlock_with(&provider, &key_secret);
        assert!(!unlocked_user_keys.user_keys.is_empty());

        let unlocked_wallet_key = locked_wallet_key
            .unlock_with(&provider, unlocked_user_keys.user_keys)
            .unwrap();
        assert_eq!(byte_key, unlocked_wallet_key.as_bytes());
    }

    #[test]
    fn test_unlock_wallet_key_signature_fail() {
        // restore the wallet key
        let armored_encrypted_message = "-----BEGIN PGP MESSAGE-----\n\nwV4DcsIsGT18EWcSAQdAYicpbmQmVa+RJ/s3NnlmQgGTa2XqY13wWTn1uY3p9AEw\nNFXNLGm6jrT11hsRwntd7a9rpk3ITvmzslGv18VJ46a2A++ynWGIO4Zb0xS5Nkpe\n0lEBaO5VSBCYtPTeptEKaLfUI69IFzOlxngTA/IYvvgn/AfvH+/BKKI5quF3v8gL\nSHUfTa0uxOLX7VNWk5UfxlNCGLxpZ7FqvlO/siOZKprKOBQ=\n=YcwK\n-----END PGP MESSAGE-----\n";
        let locked_wallet_key = LockedWalletKey::new(
            armored_encrypted_message.to_string(),
            armored_encrypted_message.to_string(),
        );
        // user key to lock the wallet
        let provider = new_pgp_provider();
        let locked_user_key = get_test_user_2_locked_user_key();
        let key_secret = get_test_user_2_locked_user_key_secret();

        let locked_keys = LockedPrivateKeys::from_primary(locked_user_key);
        let unlocked_user_keys = locked_keys.unlock_with(&provider, &key_secret);
        assert!(!unlocked_user_keys.user_keys.is_empty());

        let unlocked_wallet_key =
            locked_wallet_key.unlock_with(&provider, unlocked_user_keys.user_keys);
        assert!(unlocked_wallet_key.is_err());
        let error = unlocked_wallet_key.err();
        match error {
            Some(WalletCryptoError::CryptoError(err)) => {
                println!("{}", err);
            }
            _ => panic!("Expected WalletCryptoError::CryptoError"),
        }

        let locked_wallet_key =
            LockedWalletKey::new(armored_encrypted_message.to_string(), "".to_string());
        let locked_user_key = get_test_user_2_locked_user_key();
        let key_secret = get_test_user_2_locked_user_key_secret();
        let locked_keys = LockedPrivateKeys::from_primary(locked_user_key);
        let unlocked_user_keys = locked_keys.unlock_with(&provider, &key_secret);
        assert!(!unlocked_user_keys.user_keys.is_empty());
        let unlocked_wallet_key =
            locked_wallet_key.unlock_with(&provider, unlocked_user_keys.user_keys);
        assert!(unlocked_wallet_key.is_err());
        let error = unlocked_wallet_key.err();
        match error {
            Some(WalletCryptoError::CryptoSignatureVerify(err)) => {
                println!("{}", err);
            }
            _ => panic!("Expected WalletCryptoError::CryptoSignatureVerify"),
        }
    }

    #[test]
    fn test_unlock_wallet_key_verify_dart() {
        let byte_key = [
            239, 203, 93, 93, 253, 145, 50, 82, 227, 145, 154, 177, 206, 86, 83, 32, 251, 160, 160,
            29, 164, 144, 177, 101, 205, 128, 169, 38, 59, 33, 146, 218,
        ];
        // restore the wallet key
        let armored_encrypted_message = "-----BEGIN PGP MESSAGE-----\nComment: https://gopenpgp.org\nVersion: GopenPGP 2.7.5\n\nwV4D9Oug9vT13XESAQdAQkDaJMVbFk5TQ2XmK6qZU4rKVLV1DIccP11ljsbkqRgw\n/D/q1wGge0x3vPAAqjzRcMK7hyeIP9LCMfvjkBdS6o6E7CAROpAD7crqqHXtWt5W\n0lEBEPnoASMJSW9sPjmCzOz7OsDgXvTDefYrS8sp40y+4XVKs30m8q2oXIVYEZC6\nRK1A5P738mJ0y+chA2IOVWaLdOROM6O33lX+N8jfdsz5S+c=\n=yEP9\n-----END PGP MESSAGE-----\n";
        let armored_signature = "-----BEGIN PGP SIGNATURE-----\nVersion: GopenPGP 2.7.5\nComment: https://gopenpgp.org\n\nwpoEABYKAEwFAmbkDIkJELc30Qz6a91XFiEE6Q8m5+76nNyfDKZEtzfRDPpr3Vck\nlIAAAAAAEQAKY29udGV4dEBwcm90b24uY2h3YWxsZXQua2V5AAAgYAEApHBozjEK\nAoKM3rIdhWLbrHBq2lavIMwLNeqlXPG7zOsA/RZE9nMJNgRBq8EPa0LEtipE98LK\nq6m0IdhYgyQL3OkK\n=/dp1\n-----END PGP SIGNATURE-----\n";
        let locked_wallet_key = LockedWalletKey::new(
            armored_encrypted_message.to_string(),
            armored_signature.to_string(),
        );
        // user key to lock the wallet
        let provider = new_pgp_provider();
        let locked_user_key = get_test_user_3_locked_user_key();
        let key_secret = get_test_user_3_locked_user_key_secret();

        let locked_keys = LockedPrivateKeys::from_primary(locked_user_key);
        let unlocked_user_keys = locked_keys.unlock_with(&provider, &key_secret);
        assert!(!unlocked_user_keys.user_keys.is_empty());

        let unlocked_wallet_key = locked_wallet_key
            .unlock_with(&provider, unlocked_user_keys.user_keys)
            .unwrap();
        assert_eq!(byte_key, unlocked_wallet_key.as_bytes());
    }
}

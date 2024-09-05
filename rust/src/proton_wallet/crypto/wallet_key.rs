use aes_gcm::{
    aead::{Aead, KeyInit},
    AeadCore, Aes256Gcm, Key, Nonce,
};
use base64::{prelude::BASE64_STANDARD, Engine};

use super::{
    errors::WalletCryptoError,
    wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
};

// UnlockedWalletKey represents a key that can be used to encrypt and decrypt data.
// Wrapped in a tuple struct, it hides its internal representation while still allowing
// certain operations.
pub struct UnlockedWalletKey(pub(crate) Key<Aes256Gcm>);

impl UnlockedWalletKey {
    // TODO(feat): integrate user_key
    // Locks the wallet, returning a LockedWalletKey. A placeholder for now.
    pub fn lock_with(&self) -> LockedWalletKey {
        LockedWalletKey("".to_string())
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
    pub fn decrypt(&self, encrypted_bytes: &[u8]) -> Result<Vec<u8>, WalletCryptoError> {
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
    pub fn encrypt(&self, clear_bytes: &[u8]) -> Result<Vec<u8>, WalletCryptoError> {
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

    #[allow(dead_code)]
    fn encrypt_with_associated_data(
        &self,
        _associated_data: &[u8],
        _clear_bytes: &[u8],
    ) -> Result<Vec<u8>, WalletCryptoError> {
        unimplemented!("This function is not implemented yet. place holder for future")
    }
}

pub struct LockedWalletKey(String);
impl LockedWalletKey {
    pub fn as_bytes(&self) -> &[u8] {
        self.0.as_bytes()
    }

    // TODO(feat): integrate user_key
    pub fn unlock_with(&self) -> UnlockedWalletKey {
        WalletKeyProvider::generate()
    }
}

#[cfg(test)]
mod test {
    use crate::proton_wallet::crypto::{
        mnemonic::{EncryptedWalletMnemonic, WalletMnemonic},
        wallet_key_provider::{WalletKeyInterface, WalletKeyProvider},
    };
    use aes_gcm::{aead::Aead, AeadCore, Aes256Gcm};
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
        println!("Encryption and decryption were successful!");
    }

    #[test]
    fn test_wallet_key_restore() {
        let key_bytes: [u8; 32] = [
            109, 28, 56, 47, 162, 59, 15, 201, 117, 153, 43, 109, 252, 24, 218, 93, 13, 147, 235,
            86, 74, 233, 105, 58, 246, 122, 231, 97, 212, 118, 239, 154,
        ];

        let wallet_key = WalletKeyProvider::restore(&key_bytes);
        let cipher = wallet_key.get_cipher();
        let nonce = Aes256Gcm::generate_nonce(&mut rand::rngs::OsRng);
        let ciphertext = cipher
            .encrypt(&nonce, b"plaintext message".as_ref())
            .unwrap();
        let plaintext = cipher.decrypt(&nonce, ciphertext.as_ref()).unwrap();
        assert_eq!(&plaintext, b"plaintext message");
        println!("Encryption and decryption were successful!");
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
        println!("Encryption and decryption were successful!");
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
    }

    #[test]
    fn test_generate_and_restore_wallet_key() {
        let wallet_key = WalletKeyProvider::generate();
        let encoded_entropy = wallet_key.to_base64();
        let plain_text = "Hello world";
        println!("encoded_entropy: {}", encoded_entropy);
        let plant_body = WalletMnemonic::new_from_str(plain_text);
        let encrypted_body = plant_body.encrypt_with(&wallet_key).unwrap();
        println!("encrypted_body: {:?}", encrypted_body.to_base64());
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
        let wallet_key = WalletKeyProvider::restore(&byte_key);

        let plant_body = WalletMnemonic::new_from_str(plaintext);
        let encrypted_body = plant_body.encrypt_with(&wallet_key).unwrap();

        let clear_text_boidy = encrypted_body.decrypt_with(&wallet_key).unwrap();
        assert!(clear_text_boidy.as_utf8_string().unwrap().expose_secret() == plaintext);
    }
}

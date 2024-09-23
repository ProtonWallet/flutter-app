use core::str;

use base64::{prelude::BASE64_STANDARD, Engine};

use super::errors::WalletCryptoError;

/// A trait representing a binary data type that can be initialized from raw bytes,
/// base64-encoded strings, or plaintext strings. This trait also provides utilities
/// for converting the binary data into base64 and UTF-8 representations.
pub trait Binary {
    fn new(data: Vec<u8>) -> Self;
    fn as_bytes(&self) -> &[u8];

    /// Pre-implemented
    /// Creates an instance from a plaintext string.
    fn new_from_str(plaintext: &str) -> Self
    where
        Self: Sized,
    {
        Self::new(plaintext.as_bytes().to_vec())
    }

    /// Pre-implemented
    /// Creates an instance from a base64-encoded string.
    /// The base64 string is decoded into raw byte data.
    ///
    /// # Errors
    /// Returns a `WalletCryptoError` if the base64 string cannot be decoded.
    fn new_from_base64(base64: &str) -> Result<Self, WalletCryptoError>
    where
        Self: Sized,
    {
        Ok(Self::new(BASE64_STANDARD.decode(base64)?))
    }

    /// Pre-implemented
    /// Converts the into a base64-encoded string.
    fn to_base64(&self) -> String
    where
        Self: Sized,
    {
        BASE64_STANDARD.encode(self.as_bytes())
    }

    /// Pre-implemented
    /// Converts the byte data to a UTF-8 string.
    ///
    /// # Errors
    /// Returns a `WalletCryptoError` if the binary data cannot be converted into a valid UTF-8 string.
    fn as_utf8_string(&self) -> Result<String, WalletCryptoError>
    where
        Self: Sized,
    {
        Ok(str::from_utf8(self.as_bytes())?.to_string())
    }
}

/// A trait representing encrypted binary data. It provides methods for
/// creating encrypted instances from base64-encoded strings and converting them
/// back to base64 or UTF-8 strings for external representation.
pub trait EncryptedBinary {
    /// Creates a new `EncryptedLabel` with the provided encrypted data.
    fn new(data: Vec<u8>) -> Self;
    fn as_bytes(&self) -> &[u8];

    /// Creates an instance from a base64-encoded string.
    /// The base64 string is decoded into raw encrypted bytes.
    ///
    /// # Errors
    /// Returns a `WalletCryptoError` if the base64 string cannot be decoded.
    fn new_from_base64(base64: &str) -> Result<Self, WalletCryptoError>
    where
        Self: Sized,
    {
        Ok(BASE64_STANDARD.decode(base64).map(Self::new)?)
    }

    /// Converts the encrypted data to a base64-encoded string.
    fn to_base64(&self) -> String {
        BASE64_STANDARD.encode(self.as_bytes())
    }

    /// Pre-implemented
    /// Converts the encrypted byte data into a UTF-8 string.
    /// This should only be used for armored, encrypted data, as the raw byte data
    /// may not be valid UTF-8.
    ///
    /// # Errors
    /// Returns a `WalletCryptoError` if the binary data cannot be converted into a valid UTF-8 string.
    fn as_utf8_string(&self) -> Result<String, WalletCryptoError>
    where
        Self: Sized,
    {
        Ok(str::from_utf8(self.as_bytes())?.to_string())
    }
}

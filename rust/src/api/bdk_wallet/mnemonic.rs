// mnemonic.rs
use flutter_rust_bridge::frb;

use crate::BridgeError;
use andromeda_bitcoin::{
    mnemonic::{get_words_autocomplete, Mnemonic},
    WordCount,
};

#[derive(Debug)]
pub struct FrbMnemonic {
    inner: Mnemonic,
}

impl FrbMnemonic {
    /// Create a new Mnemonic with the given word count.
    #[frb(sync)]
    pub fn new(word_count: WordCount) -> Result<FrbMnemonic, BridgeError> {
        let mnemonic = Mnemonic::new(word_count.into())?;
        Ok(FrbMnemonic { inner: mnemonic })
    }

    /// Parse a Mnemonic with the given string.
    #[frb(sync)]
    pub fn from_string(mnemonic: String) -> Result<FrbMnemonic, BridgeError> {
        let mnemonic = Mnemonic::from_string(mnemonic)?;
        Ok(FrbMnemonic {
            inner: mnemonic.into(),
        })
    }

    #[frb(sync)]
    pub(crate) fn from_str(mnemonic: &str) -> Result<FrbMnemonic, BridgeError> {
        Self::from_string(mnemonic.to_string())
    }

    /// Create a new Mnemonic in the specified language from the given entropy.
    /// Entropy must be a multiple of 32 bits (4 bytes) and 128-256 bits in length.
    // pub fn from_entropy(entropy: Vec<u8>) -> Result<Self, BridgeError> {
    //     BdkMnemonic::from_entropy(entropy.as_slice())
    // }

    /// Returns the Mnemonic as a string.
    #[frb(sync)]
    pub fn as_string(&self) -> String {
        self.inner.as_string()
    }

    /// Returns the mnemonic as words array
    #[frb(sync)]
    pub fn as_words(&self) -> Vec<String> {
        self.inner.as_words()
    }

    #[frb(sync)]
    pub fn get_words_autocomplete(word_start: String) -> Vec<String> {
        get_words_autocomplete(word_start)
    }
}

// mnemonic.rs
use andromeda_bitcoin::{
    mnemonic::{get_words_autocomplete, Mnemonic},
    WordCount,
};
use flutter_rust_bridge::frb;

use crate::BridgeError;

#[derive(Debug)]
pub struct FrbMnemonic {
    pub(crate) inner: Mnemonic,
}

impl FrbMnemonic {
    /// Create a new Mnemonic with the given word count.
    #[frb(sync)]
    pub fn new(word_count: WordCount) -> Result<FrbMnemonic, BridgeError> {
        let mnemonic = Mnemonic::new(word_count.into())?;
        Ok(FrbMnemonic { inner: mnemonic })
    }

    #[frb(sync)]
    pub fn new_with(entropy: Vec<u8>) -> Result<FrbMnemonic, BridgeError> {
        let mnemonic = Mnemonic::new_with(&entropy)?;
        Ok(FrbMnemonic {
            inner: mnemonic.into(),
        })
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

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

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;

    const ITERATIONS: usize = 1_000_000;
    const PROGRESS_EVERY: usize = 10_000;

    /// Based on the birthday paradox, the probability of a real BIP39 mnemonic
    /// collision is extremely low (approximately 1.5 × 10⁻²⁷ for 1 million
    /// generated 12-word mnemonics). This test is not intended to prove
    /// cryptographic randomness; instead, it is designed to catch implementation
    /// issues such as reused entropy, fixed seeds, or incorrect wallet
    /// generation flows.
    #[test]
    fn bip39_mnemonic_no_collision_1m() {
        let mut seen: HashMap<String, usize> = HashMap::new();

        for iteration in 1..=ITERATIONS {
            let mnemonic = FrbMnemonic::new(WordCount::Words12)
                .expect("failed to generate mnemonic")
                .as_string();

            if let Some(first_iteration) = seen.get(&mnemonic) {
                panic!(
                    "BIP39 mnemonic collision at iteration {iteration} \
                     (same as iteration {first_iteration}): {mnemonic}"
                );
            }
            seen.insert(mnemonic, iteration);

            if iteration % PROGRESS_EVERY == 0 {
                eprintln!(
                    "[bip39-collision] iteration {iteration}/{ITERATIONS} | unique: {}",
                    seen.len()
                );
            }
        }

        assert_eq!(seen.len(), ITERATIONS);
        eprintln!(
            "[bip39-collision] passed: {ITERATIONS} iterations, all mnemonics unique"
        );
    }
}

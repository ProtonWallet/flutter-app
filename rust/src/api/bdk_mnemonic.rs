// use crate::bdk_common::{error::Error, word_count::WordCount};

// pub struct RustMnemonic {
//     pub inner: andromeda_bitcoin::mnemonic::Mnemonic,
// }

// // #[wasm_bindgen]
// impl RustMnemonic {
//     /// Generates a Mnemonic with a random entropy based on the given word count.
//     pub fn new(word_count: WordCount) -> Result<RustMnemonic, Error> {
//         let result = andromeda_bitcoin::mnemonic::Mnemonic::new(word_count.into());
//         match result {
//             Ok(mnemonic) => Ok(RustMnemonic { inner: mnemonic }),
//             Err(e) => Err(e.into()),
//         }
//     }

//     pub fn from_string(mnemonic: String) -> Result<RustMnemonic, Error> {
//         let result = andromeda_bitcoin::mnemonic::Mnemonic::from_string(mnemonic);
//         match result {
//             Ok(mnemonic) => Ok(RustMnemonic { inner: mnemonic }),
//             Err(e) => Err(e.into()),
//         }
//     }

//     /// Returns the Mnemonic as a string.
//     pub fn as_string(&self) -> String {
//         self.inner.as_string()
//     }

//     // Returns the mnemonic as words array
//     pub fn as_words(&self) -> Vec<String> {
//         self.inner.as_words()
//     }
// }

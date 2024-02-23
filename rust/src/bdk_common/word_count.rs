use andromeda_bitcoin::WordCount as BdkWordCount;

/// Type describing entropy length (aka word count) in the mnemonic
pub enum WordCount {
    ///12 words mnemonic (128 bits entropy)
    Words12,
    ///15 words mnemonic (160 bits entropy)
    Words15,
    ///18 words mnemonic (192 bits entropy)
    Words18,
    ///21 words mnemonic (224 bits entropy)
    Words21,
    ///24 words mnemonic (256 bits entropy)
    Words24,
}

impl From<WordCount> for BdkWordCount {
    fn from(word_count: WordCount) -> Self {
        match word_count {
            WordCount::Words12 => BdkWordCount::Words12,
            WordCount::Words15 => BdkWordCount::Words15,
            WordCount::Words18 => BdkWordCount::Words18,
            WordCount::Words21 => BdkWordCount::Words21,
            WordCount::Words24 => BdkWordCount::Words24,
        }
    }
}
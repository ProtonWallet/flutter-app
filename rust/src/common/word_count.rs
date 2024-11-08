// word_count.rs
pub use andromeda_bitcoin::WordCount;
use flutter_rust_bridge::frb;

#[frb(mirror(WordCount))]
pub enum _WordCount {
    /// 12 words mnemonic (128 bits entropy)
    Words12 = 128,
    /// 15 words mnemonic (160 bits entropy)
    Words15 = 160,
    /// 18 words mnemonic (192 bits entropy)
    Words18 = 192,
    /// 21 words mnemonic (224 bits entropy)
    Words21 = 224,
    /// 24 words mnemonic (256 bits entropy)
    Words24 = 256,
}

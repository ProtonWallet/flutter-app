// script_type.rs
pub use andromeda_common::ScriptType;
use flutter_rust_bridge::frb;

#[frb(mirror(ScriptType))]
pub enum _ScriptType {
    /// Legacy scripts : https://bitcoinwiki.org/wiki/pay-to-pubkey-hash
    Legacy, // = 1,
    /// Nested segwit scrips : https://bitcoinwiki.org/wiki/pay-to-script-hash
    NestedSegwit, // = 2,
    /// Native segwit scripts : https://bips.dev/173/
    NativeSegwit, // = 3,
    /// Taproot scripts : https://bips.dev/341/
    Taproot, // = 4,
}

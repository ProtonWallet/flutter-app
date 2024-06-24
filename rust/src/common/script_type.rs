// script_type.rs
use flutter_rust_bridge::frb;

pub use andromeda_common::ScriptType;

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

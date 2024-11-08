// keychain_kind.rs
pub use andromeda_bitcoin::KeychainKind;
use flutter_rust_bridge::frb;

#[frb(mirror(KeychainKind))]
pub enum _KeychainKind {
    /// External keychain, used for deriving recipient addresses.
    External = 0,
    /// Internal keychain, used for deriving change addresses.
    Internal = 1,
}

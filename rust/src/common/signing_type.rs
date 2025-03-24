// script_type.rs
pub use andromeda_bitcoin::SigningType;
use flutter_rust_bridge::frb;

#[frb(mirror(SigningType))]
pub enum _SigningType {
    Electrum,
    Bip137,
}

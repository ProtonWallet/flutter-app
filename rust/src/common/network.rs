// network.rs
use flutter_rust_bridge::frb;

pub use andromeda_common::Network;

#[frb(mirror(Network))]
pub enum _Network {
    /// Mainnet Bitcoin.
    Bitcoin,
    /// Bitcoin's testnet network.
    Testnet,
    /// Bitcoin's signet network.
    Signet,
    /// Bitcoin's regtest network.
    Regtest,
}

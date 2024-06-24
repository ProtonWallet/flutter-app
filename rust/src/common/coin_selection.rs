// coin_selection.rs

pub use andromeda_bitcoin::transaction_builder::CoinSelection;
use flutter_rust_bridge::frb;

#[frb(mirror(CoinSelection))]
pub enum _CoinSelection {
    BranchAndBound,
    LargestFirst,
    OldestFirst,
    Manual,
}

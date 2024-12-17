pub use andromeda_api::transaction::RecommendedFees;
use flutter_rust_bridge::frb;

#[frb(mirror(RecommendedFees))]
#[allow(non_snake_case)]
pub struct _RecommendedFees {
    /// Fee rate in sat/vB to place the transaction in the first mempool block
    pub FastestFee: u8,
    /// Fee rate in sat/vB to usually confirm within half hour and place the transaction in between the first and second mempool blocks
    pub HalfHourFee: u8,
    /// Fee rate in sat/vB to usually confirm within one hour and place the transaction in between the second and third mempool blocks
    pub HourFee: u8,
    /// Either 2 times the minimum fees, or the low priority rate (whichever is lower)
    pub EconomyFee: u8,
    /// Minimum fee rate in sat/vB for transaction to be accepted
    pub MinimumFee: u8,
}

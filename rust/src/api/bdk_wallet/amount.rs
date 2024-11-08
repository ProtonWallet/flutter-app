// amount.rs
use andromeda_bitcoin::Amount as BdkAmount;
use flutter_rust_bridge::frb;

#[derive(Debug, Copy, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct FrbAmount {
    pub(crate) inner: BdkAmount,
}

impl From<BdkAmount> for FrbAmount {
    fn from(amount: BdkAmount) -> Self {
        FrbAmount { inner: amount }
    }
}

impl FrbAmount {
    /// Gets the number of satoshis in this [`Amount`].
    #[frb(sync)]
    pub fn to_sat(self) -> u64 {
        self.inner.to_sat()
    }

    #[frb(sync)]
    pub fn to_btc(self) -> f64 {
        self.inner.to_btc()
    }
}

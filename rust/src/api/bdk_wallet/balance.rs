// balance.rs
use andromeda_bitcoin::Balance;
use flutter_rust_bridge::frb;

use super::amount::FrbAmount;

#[derive(Debug, PartialEq, Eq, Clone, Default)]
pub struct FrbBalance {
    pub(crate) inner: Balance,
}

impl From<Balance> for FrbBalance {
    fn from(balance: Balance) -> Self {
        FrbBalance { inner: balance }
    }
}

impl FrbBalance {
    /// Get sum of trusted_pending and confirmed coins.
    ///
    /// This is the balance you can spend right now that shouldn't get cancelled via another party
    /// double spending it.
    #[frb(sync)]
    pub fn trusted_spendable(&self) -> FrbAmount {
        self.inner.trusted_spendable().into()
    }

    /// Get the whole balance visible to the wallet.
    #[frb(sync)]
    pub fn total(&self) -> FrbAmount {
        self.inner.total().into()
    }
}

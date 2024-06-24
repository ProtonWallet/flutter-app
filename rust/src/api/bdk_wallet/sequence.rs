// sequence.rs
use flutter_rust_bridge::frb;

use andromeda_bitcoin::Sequence as BdkSequence;

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct FrbSequence {
    inner: BdkSequence,
}

impl From<BdkSequence> for FrbSequence {
    fn from(sequence: BdkSequence) -> Self {
        FrbSequence { inner: sequence }
    }
}

impl FrbSequence {
    /// Returns `true` if the sequence number indicates that the transaction is finalized.
    #[inline]
    #[frb(sync)]
    pub fn is_final(&self) -> bool {
        self.inner.is_final()
    }

    /// Returns true if the transaction opted-in to BIP125 replace-by-fee.
    #[inline]
    #[frb(sync)]
    pub fn is_rbf(&self) -> bool {
        self.inner.is_rbf()
    }

    /// Returns `true` if the sequence has a relative lock-time.
    #[inline]
    #[frb(sync)]
    pub fn is_relative_lock_time(&self) -> bool {
        self.inner.is_relative_lock_time()
    }

    /// Returns `true` if the sequence number encodes a block based relative lock-time.
    #[inline]
    #[frb(sync)]
    pub fn is_height_locked(&self) -> bool {
        self.inner.is_height_locked()
    }

    /// Returns `true` if the sequence number encodes a time interval based relative lock-time.
    #[inline]
    #[frb(sync)]
    pub fn is_time_locked(&self) -> bool {
        self.inner.is_time_locked()
    }
}

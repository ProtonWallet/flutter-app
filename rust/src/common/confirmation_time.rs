// confirmation_time.rs
pub use andromeda_bitcoin::ConfirmationTime;
use flutter_rust_bridge::frb;

#[frb(mirror(ConfirmationTime))]
pub enum _ConfirmationTime {
    /// The transaction is confirmed
    Confirmed {
        /// Confirmation height.
        height: u32,
        /// Confirmation time in unix seconds.
        time: u64,
    },
    /// The transaction is unconfirmed
    Unconfirmed {
        /// The last-seen timestamp in unix seconds.
        last_seen: u64,
    },
}

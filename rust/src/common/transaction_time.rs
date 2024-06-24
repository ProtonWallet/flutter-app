// transaction_time.rs
use flutter_rust_bridge::frb;

pub use andromeda_bitcoin::transactions::TransactionTime;

#[frb(mirror(TransactionTime))]
pub enum _TransactionTime {
    Confirmed { confirmation_time: u64 },
    Unconfirmed { last_seen: u64 },
}

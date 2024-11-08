// transaction_time.rs
pub use andromeda_bitcoin::transactions::TransactionTime;
use flutter_rust_bridge::frb;

#[frb(mirror(TransactionTime))]
pub enum _TransactionTime {
    Confirmed { confirmation_time: u64 },
    Unconfirmed { last_seen: u64 },
}

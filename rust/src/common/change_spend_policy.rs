// change_spend_policy.rs
pub use andromeda_bitcoin::ChangeSpendPolicy;
use flutter_rust_bridge::frb;

#[frb(mirror(ChangeSpendPolicy))]
pub enum _ChangeSpendPolicy {
    ChangeAllowed,
    OnlyChange,
    ChangeForbidden,
}

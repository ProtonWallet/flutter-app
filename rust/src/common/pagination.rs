// pagination.rs
pub use andromeda_bitcoin::{transactions::Pagination, utils::SortOrder, utils::TransactionFilter};
use flutter_rust_bridge::frb;

#[frb(mirror(Pagination))]
pub struct _Pagination {
    pub skip: usize,
    pub take: usize,
}

#[frb(mirror(SortOrder))]
pub enum _SortOrder {
    Asc,
    Desc,
}

#[frb(mirror(TransactionFilter))]
pub enum _TransactionFilter {
    All,
    Receive,
    Send,
}

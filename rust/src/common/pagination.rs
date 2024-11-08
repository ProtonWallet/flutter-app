// pagination.rs
pub use andromeda_bitcoin::{transactions::Pagination, utils::SortOrder};
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

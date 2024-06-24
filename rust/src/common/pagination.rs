// pagination.rs
use flutter_rust_bridge::frb;

pub use andromeda_bitcoin::transactions::Pagination;
pub use andromeda_bitcoin::utils::SortOrder;

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

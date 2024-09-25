use rusqlite::{Result, Row};

pub trait ModelBase
where
    Self: Sized,
{
    fn from_row(row: &Row) -> Result<Self>;
}

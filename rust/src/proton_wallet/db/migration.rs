use super::error::DatabaseError;

pub trait Migration: Send + Sync {
    // fn start_version(&self) -> i32;
    // fn end_version(&self) -> i32;

    fn migrate(&self) -> impl std::future::Future<Output = Result<(), DatabaseError>> + Send;
}

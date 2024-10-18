pub mod app_database;
pub mod dao;
pub mod database;
pub mod error;
pub mod model;

pub type Result<T, E = error::DatabaseError> = std::result::Result<T, E>;

#[derive(thiserror::Error, Debug)]
pub enum DatabaseError {
    #[error("An error occurred in rust sqlite: \n\t{0}")]
    Database(#[from] rusqlite::Error),
    #[error("An database migration error occured: {0}")]
    Migration(String),
    #[error("Database operation column not found: {0}")]
    ColumnNotFound(String),
    #[error("Database operation update failed")]
    UpdateFailed,
    #[error("Database operation update no row changed")]
    NoChangedRows,
}

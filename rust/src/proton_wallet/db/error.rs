#[derive(thiserror::Error, Debug)]
pub enum DatabaseError {
    #[error("An error occurred in rust sqlite: \n\t{0}")]
    Database(#[from] rusqlite::Error),
}

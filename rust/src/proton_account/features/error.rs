#[derive(Debug, thiserror::Error)]
pub enum AccountFeaturesError {
    #[error("Andromeda api error: {0}")]
    AndromedaApi(#[from] andromeda_api::error::Error),
}

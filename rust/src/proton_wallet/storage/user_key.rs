pub struct UserKeyStorage {}

impl UserKeyStorage {
    pub fn new() -> UserKeyStorage {
        UserKeyStorage {}
    }

    /// Get the primary user key
    pub fn get_primary_key(&self) -> Result<(), Box<dyn std::error::Error>> {
        Ok(())
    }
}

impl Default for UserKeyStorage {
    fn default() -> Self {
        Self::new()
    }
}

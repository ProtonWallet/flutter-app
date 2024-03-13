pub struct Lighting {}

impl Default for Lighting {
    fn default() -> Self {
        Self::new()
    }
}

impl Lighting {
    pub fn new() -> Lighting {
        Lighting {}
    }

    pub fn test_lightning(&self) -> String {
        "error".to_string()
    }
}

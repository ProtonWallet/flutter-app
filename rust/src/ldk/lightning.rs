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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_lighting() {
        let lighting = Lighting::default();
        let new_lighting = Lighting::new();
        assert_eq!(lighting.test_lightning(), new_lighting.test_lightning());

        let result = lighting.test_lightning();
        assert_eq!(result, "error");
    }
}

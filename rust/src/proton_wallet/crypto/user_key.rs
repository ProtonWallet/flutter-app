/// place holder
pub struct UserKey {}
impl UserKey {
    pub fn new() -> Self {
        Self {}
    }
}

impl Default for UserKey {
    fn default() -> Self {
        Self::new()
    }
}

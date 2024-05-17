pub struct RustAccount {
    pub inner: std::sync::Arc<
        std::sync::RwLock<andromeda_bitcoin::account::Account<bdk::database::SqliteDatabase>>,
    >,
}

impl RustAccount {
    pub fn get_balance(&self) -> Result<Balance, Error> {
        let result = self.inner.read().expect("lock").get_balance();
        match result {
            Ok(balance) => Ok(balance),
            Err(e) => Err(e),
        }
    }
}

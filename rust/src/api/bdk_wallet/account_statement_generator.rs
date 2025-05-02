use andromeda_features::account_statement_generator::AccountStatementGenerator;
use flutter_rust_bridge::frb;

use crate::{exchange_rate::ProtonExchangeRate, BridgeError};

use super::account::FrbAccount;

#[derive(Clone)]
pub struct FrbAccountStatementGenerator {
    inner: AccountStatementGenerator,
}

impl FrbAccountStatementGenerator {
    #[frb(sync)]
    pub fn new(exchange_rate: Option<ProtonExchangeRate>) -> Self {
        Self {
            inner: AccountStatementGenerator::new(vec![], vec![], exchange_rate.map(|e| e.into())),
        }
    }

    #[frb(sync)]
    pub fn add_account(&mut self, account: &FrbAccount, account_name: String) {
        self.inner.add_account(account.get_inner(), account_name);
    }
}

impl FrbAccountStatementGenerator {
    pub async fn to_pdf(&mut self, export_time: u64) -> Result<Vec<u8>, BridgeError> {
        Ok(self.inner.to_pdf(export_time).await?)
    }

    pub async fn to_csv(&mut self, export_time: u64) -> Result<Vec<u8>, BridgeError> {
        Ok(self.inner.to_csv(export_time).await?)
    }
}

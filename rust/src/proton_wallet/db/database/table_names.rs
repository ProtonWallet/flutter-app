// const table names to prevent typos and injections
#[derive(Debug, Clone)]
pub enum TableName {
    Accounts,
    Address,
    BitcoinAddress,
    Contacts,
    ExchangeRate,
    ProtonUserKey,
    ProtonUser,
    Transactions,
    WalletUserSettings,
    Wallet,
}

impl TableName {
    pub fn as_str(&self) -> &'static str {
        match self {
            TableName::Accounts => "account_table",
            TableName::Address => "address_table",
            TableName::BitcoinAddress => "bitcoin_address_table",
            TableName::Contacts => "contacts_table",
            TableName::ExchangeRate => "exchange_rate_table",
            TableName::ProtonUserKey => "user_keys_table",
            TableName::ProtonUser => "users_table",
            TableName::Transactions => "transaction_table",
            TableName::WalletUserSettings => "wallet_user_settings_table",
            TableName::Wallet => "wallet_table",
        }
    }
}

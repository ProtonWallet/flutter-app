use std::error::Error;

#[derive(Copy, Clone, Hash, PartialEq, Eq)]
pub enum Dataupdate {
    UpsertWallet = 10000,
    UpsertWalletAccount = 10001,
    UpsertContacts = 10002,
    UpsertTransaction = 10003,
    UpsertAddress = 10004,
    UpsertExchangeRate = 10005,
    UpsertBitcoinAddress = 10006,
    UpsertWalletUserSettings = 10007,

    DeleteWallet = 20000,
    DeleteWalletAccount = 20001,
    DeleteContacts = 20002,
    DeleteTransaction = 20003,
    DeleteAddress = 20004,
    DeleteExchangeRate = 20005,
    DeleteBitcoinAddress = 20006,
    DeleteWalletUserSettings = 20007,
}

/// we can add a cache for data provider if needed
/// so far we only get datas from db via dao directly to keep the logic simple
pub trait DataProvider<T> {
    fn upsert(
        &mut self,
        item: T,
    ) -> impl std::future::Future<Output = Result<(), Box<dyn Error>>> + Send;
    fn get(
        &mut self,
        server_id: &str,
    ) -> impl std::future::Future<Output = Result<Option<T>, Box<dyn Error>>> + Send;
}

use super::provider::DataProvider;
use crate::proton_wallet::db::dao::{account_dao::AccountDao, wallet_dao::WalletDao};
use crate::proton_wallet::db::model::{account_model::AccountModel, wallet_model::WalletModel};
use std::error::Error;

pub struct WalletDataProvider {
    wallet_dao: WalletDao,
    account_dao: AccountDao,
}

impl WalletDataProvider {
    pub fn new(wallet_dao: WalletDao, account_dao: AccountDao) -> Self {
        WalletDataProvider {
            wallet_dao: wallet_dao,
            account_dao: account_dao,
        }
    }

    pub async fn delete_by_wallet_id(&mut self, wallet_id: &str) -> Result<(), Box<dyn Error>> {
        let result = self.wallet_dao.delete_by_wallet_id(wallet_id).await;
        result?;

        Ok(())
    }

    pub async fn get_all_by_user_id(
        &mut self,
        user_id: &str,
    ) -> Result<Vec<WalletModel>, Box<dyn Error>> {
        Ok(self.wallet_dao.get_all_by_user_id(user_id).await?)
    }

    pub async fn get_new_derivation_path(
        &mut self,
        wallet_id: &str,
        bip_version: u32,
        coin_type: u32,
    ) -> Result<String, Box<dyn Error>> {
        let mut new_account_index = 0;

        let accounts = self.account_dao.get_all_by_wallet_id(wallet_id).await?;

        loop {
            let derivation_path =
                self.format_derivation_path(bip_version, coin_type, new_account_index);

            if self.is_derivation_path_exist(&accounts, &derivation_path)
                || self.is_derivation_path_exist(&accounts, &format!("m/{}", derivation_path))
            {
                new_account_index += 1;

                // exceed searching max
                if new_account_index > 10000 {
                    break;
                }
            } else {
                return Ok(derivation_path);
            }
        }

        Err("Accounts already full (maximum account size = 10,000)".into())
    }

    fn is_derivation_path_exist(
        &mut self,
        accounts: &Vec<AccountModel>,
        derivation_path: &String,
    ) -> bool {
        for account in accounts {
            if &account.derivation_path == derivation_path {
                return true;
            }
        }

        false
    }

    fn format_derivation_path(
        &mut self,
        bip_version: u32,
        coin_type: u32,
        account_index: u32,
    ) -> String {
        let path = format!("{}'/{}'/{}'", bip_version, coin_type, account_index);

        path
    }
}

impl DataProvider<WalletModel> for WalletDataProvider {
    async fn upsert(&mut self, item: WalletModel) -> Result<(), Box<dyn Error>> {
        let result = self.wallet_dao.upsert(&item).await;
        result?;

        Ok(())
    }

    async fn get(&mut self, server_id: &str) -> Result<Option<WalletModel>, Box<dyn Error>> {
        Ok(self.wallet_dao.get_by_server_id(server_id).await?)
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::dao::{account_dao::AccountDao, wallet_dao::WalletDao};
    use crate::proton_wallet::db::model::{account_model::AccountModel, wallet_model::WalletModel};
    use crate::proton_wallet::provider::{provider::DataProvider, wallet::WalletDataProvider};
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_wallet_provider() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let wallet_dao = WalletDao::new(conn_arc.clone());
        let _ = wallet_dao.database.migration_0().await;
        let account_dao = AccountDao::new(conn_arc.clone());
        let _ = account_dao.database.migration_0().await;
        let _ = account_dao.database.migration_1().await;
        let mut wallet_provider = WalletDataProvider::new(wallet_dao.clone(), account_dao.clone());

        let wallet1 = WalletModel {
            id: 1,
            name: "MyWallet".to_string(),
            passphrase: 0,
            public_key: "binary_encoded_string".to_string(),
            imported: 0,
            priority: 5,
            status: 1,
            type_: 2,
            create_time: 1633072800,
            modify_time: 1633159200,
            user_id: "user123".to_string(),
            wallet_id: "wallet123".to_string(),
            account_count: 3,
            balance: 150.75,
            fingerprint: Some("abc123xyz".to_string()),
            show_wallet_recovery: 1,
            migration_required: 0,
        };
        let wallet2 = WalletModel {
            id: 2,
            name: "MyWallet2".to_string(),
            passphrase: 0,
            public_key: "binary_encoded_string2".to_string(),
            imported: 0,
            priority: 1,
            status: 1,
            type_: 2,
            create_time: 1633072800,
            modify_time: 1633159200,
            user_id: "user123".to_string(),
            wallet_id: "wallet123456".to_string(),
            account_count: 2,
            balance: 10.2,
            fingerprint: Some("abc456xyz".to_string()),
            show_wallet_recovery: 1,
            migration_required: 0,
        };
        let _ = wallet_provider.upsert(wallet1).await;
        // match result {
        //     Ok(()) => println!("Wallet upserted successfully!"),
        //     Err(e) => eprintln!("Error occurred while upserting wallet: {}", e),
        // }
        let _ = wallet_provider.upsert(wallet2).await;

        let wallets = wallet_provider.get_all_by_user_id("user123").await.unwrap();
        assert_eq!(wallets.len(), 2);

        let wallet = wallet_provider.get("wallet123").await.unwrap().unwrap();
        assert_eq!(wallet.name, "MyWallet");
        assert_eq!(wallet.public_key, "binary_encoded_string");
        assert_eq!(wallet.fingerprint.unwrap(), "abc123xyz");

        let wallet = wallet_provider.get("wallet123456").await.unwrap().unwrap();
        assert_eq!(wallet.name, "MyWallet2");
        assert_eq!(wallet.public_key, "binary_encoded_string2");
        assert_eq!(wallet.fingerprint.unwrap(), "abc456xyz");

        let wallet = wallet_provider.get("wallet123456").await.unwrap().unwrap();
        assert_eq!(wallet.name, "MyWallet2");
        assert_eq!(wallet.public_key, "binary_encoded_string2");
        assert_eq!(wallet.fingerprint.unwrap(), "abc456xyz");

        let _ = wallet_provider.delete_by_wallet_id("wallet123456");

        // test update
        let mut wallet = wallet_provider.get("wallet123").await.unwrap().unwrap();
        wallet.name = "New Name".to_string();

        let _ = wallet_provider.upsert(wallet).await;

        let wallet = wallet_provider.get("wallet123").await.unwrap().unwrap();
        assert_eq!(wallet.name, "New Name");
        assert_eq!(wallet.public_key, "binary_encoded_string");
        assert_eq!(wallet.fingerprint.unwrap(), "abc123xyz");

        // test get new derivation path
        let derivation_path = wallet_provider
            .get_new_derivation_path("wallet123", 84, 0)
            .await
            .unwrap();
        assert_eq!(derivation_path, "84'/0'/0'");

        let account_model1 = AccountModel {
            id: 1,
            account_id: "account1".to_string(),
            wallet_id: "wallet123".to_string(),
            derivation_path: "m/84'/0'/0'".to_string(),
            label: "My Account Label 1".to_string(),
            script_type: 0,
            create_time: 1633072800,
            modify_time: 1633159200,
            fiat_currency: "USD".to_string(),
            priority: 10,
            last_used_index: 5,
            pool_size: 100,
        };

        let account_model2 = AccountModel {
            id: 2,
            account_id: "account2".to_string(),
            wallet_id: "wallet123".to_string(),
            derivation_path: "m/84'/0'/1'".to_string(),
            label: "My Account Label 2".to_string(),
            script_type: 0,
            create_time: 1633072800,
            modify_time: 1633159200,
            fiat_currency: "MMR".to_string(),
            priority: 11,
            last_used_index: 0,
            pool_size: 100,
        };
        let _ = account_dao.upsert(&account_model1).await;
        let _ = account_dao.upsert(&account_model2).await;

        let derivation_path = wallet_provider
            .get_new_derivation_path("wallet123", 84, 0)
            .await
            .unwrap();
        assert_eq!(derivation_path, "84'/0'/2'");
    }
}

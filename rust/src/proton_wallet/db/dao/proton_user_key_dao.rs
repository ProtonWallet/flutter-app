use async_trait::async_trait;
use rusqlite::{params, Connection};
use std::sync::Arc;
use tokio::sync::Mutex;

use crate::proton_wallet::db::{
    database::{database::BaseDatabase, proton_user_key::ProtonUserKeyDatabase},
    error::DatabaseError,
    model::proton_user_key_model::ProtonUserKeyModel,
    Result,
};

#[derive(Debug)]
pub struct ProtonUserKeyDaoImpl {
    conn: Arc<Mutex<Connection>>,
    pub database: ProtonUserKeyDatabase,
}

#[async_trait]
pub trait ProtonUserKeyDao: Send + Sync {
    async fn upsert(&self, item: &ProtonUserKeyModel) -> Result<Option<ProtonUserKeyModel>>;

    async fn get_all_by_user_id(&self, user_id: &str) -> Result<Vec<ProtonUserKeyModel>>;

    async fn get_by_key_id(&self, key_id: &str) -> Result<Option<ProtonUserKeyModel>>;
}

#[async_trait]
impl ProtonUserKeyDao for ProtonUserKeyDaoImpl {
    async fn upsert(&self, item: &ProtonUserKeyModel) -> Result<Option<ProtonUserKeyModel>> {
        if self.get_by_key_id(&item.key_id).await?.is_some() {
            self.update(item).await?;
        } else {
            self.insert(item).await?;
        }
        self.get_by_key_id(&item.key_id).await
    }

    async fn get_all_by_user_id(&self, user_id: &str) -> Result<Vec<ProtonUserKeyModel>> {
        self.database.get_all_by_column_id("user_id", user_id).await
    }

    async fn get_by_key_id(&self, key_id: &str) -> Result<Option<ProtonUserKeyModel>> {
        self.database.get_by_column_id("key_id", key_id).await
    }
}

impl ProtonUserKeyDaoImpl {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        let database = ProtonUserKeyDatabase::new(conn.clone());
        Self { conn, database }
    }

    /// Helper to get a locked connection
    async fn get_conn(&self) -> Result<tokio::sync::MutexGuard<'_, Connection>, rusqlite::Error> {
        Ok(self.conn.lock().await)
    }

    pub async fn insert(&self, item: &ProtonUserKeyModel) -> Result<u32> {
        let conn = self.get_conn().await?;
        conn.execute(
            "INSERT INTO user_keys_table (key_id, user_id, version, private_key, token, fingerprint, recovery_secret, recovery_secret_signature, active, 'primary') 
            VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)",
            params![
                item.key_id,
                item.user_id,
                item.version,
                item.private_key,
                item.token,
                item.fingerprint,
                item.recovery_secret,
                item.recovery_secret_signature,
                item.active,
                item.primary,
            ],
        )
        .map_err(DatabaseError::from)?;

        Ok(conn.last_insert_rowid() as u32)
    }

    pub async fn update(&self, item: &ProtonUserKeyModel) -> Result<()> {
        let conn = self.get_conn().await?;
        let rows_affected = conn.execute(
            "UPDATE user_keys_table SET 
                user_id = ?1,
                version = ?2, 
                private_key = ?3, 
                token = ?4, 
                fingerprint = ?5, 
                recovery_secret = ?6, 
                recovery_secret_signature = ?7, 
                active = ?8, 
                'primary' = ?9 
                WHERE key_id = ?10",
            params![
                item.user_id,
                item.version,
                item.private_key,
                item.token,
                item.fingerprint,
                item.recovery_secret,
                item.recovery_secret_signature,
                item.active,
                item.primary,
                item.key_id,
            ],
        )?;

        if rows_affected == 0 {
            return Err(DatabaseError::UpdateFailed);
        }
        Ok(())
    }

    pub async fn get_all(&self) -> Result<Vec<ProtonUserKeyModel>> {
        Ok(self.database.get_all().await?)
    }
}

#[cfg(test)]
#[cfg(feature = "mocking")]
pub mod mock {
    use super::*;
    use async_trait::async_trait;
    use mockall::mock;
    mock! {
        pub ProtonUserKeyDao {}
        #[async_trait]
        impl ProtonUserKeyDao for ProtonUserKeyDao {
            async fn upsert(&self, item: &ProtonUserKeyModel) -> Result<Option<ProtonUserKeyModel>>;
            async fn get_all_by_user_id(&self, user_id: &str) -> Result<Vec<ProtonUserKeyModel>>;
            async fn get_by_key_id(&self, key_id: &str) -> Result<Option<ProtonUserKeyModel>>;
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::{
        dao::proton_user_key_dao::{ProtonUserKeyDao, ProtonUserKeyDaoImpl},
        model::proton_user_key_model::ProtonUserKeyModel,
    };
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_proton_user_key_dao_from_local_file() {
        let db_path = "./test_proton_wallet_rust_db.sqlite".to_string();
        let conn_arc = Arc::new(Mutex::new(Connection::open(db_path).unwrap()));
        let proton_user_key_dao = ProtonUserKeyDaoImpl::new(conn_arc);
        proton_user_key_dao.database.migration_0().await.unwrap();
        let user_keys = proton_user_key_dao.get_all().await.unwrap();
        assert_eq!(user_keys.len(), 0);
    }

    #[tokio::test]
    async fn test_proton_user_key_dao() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        {
            // create table
            let conn_arc_cp = Arc::clone(&conn_arc);
            let conn = conn_arc_cp.lock().await;
            let _ = conn.execute(
                r#"
                CREATE TABLE IF NOT EXISTS user_keys_table (
                key_id TEXT NOT NULL, 
                user_id TEXT NOT NULL, 
                version INTEGER NOT NULL, 
                private_key TEXT NOT NULL, 
                token TEXT NULL, 
                fingerprint TEXT NULL, 
                recovery_secret TEXT NULL, 
                recovery_secret_signature TEXT NULL, 
                active INTEGER NOT NULL,
                'primary' INTEGER NOT NULL, 
                PRIMARY KEY (key_id, user_id))
                "#,
                [],
            );
        }
        let proton_user_key_dao = ProtonUserKeyDaoImpl::new(conn_arc);
        let user_keys = proton_user_key_dao.get_all().await.unwrap();
        assert_eq!(user_keys.len(), 0);

        let user_key = ProtonUserKeyModel {
            key_id: "mock_key_id".to_string(),
            user_id: "mock_user_id".to_string(),
            version: 233,
            private_key: "mock_private_key_here".to_string(),
            token: Some("mock_token".to_string()),
            fingerprint: Some("FTS721AVC2US".to_string()),
            recovery_secret: None,
            recovery_secret_signature: None,
            active: 1,
            primary: 1,
        };

        let user_key_1 = ProtonUserKeyModel {
            key_id: "mock_key_id_1".to_string(),
            user_id: "mock_user_id".to_string(),
            version: 233,
            private_key: "mock_private_key_here_1".to_string(),
            token: Some("mock_token_1".to_string()),
            fingerprint: Some("SUIGUG125".to_string()),
            recovery_secret: None,
            recovery_secret_signature: None,
            active: 1,
            primary: 0,
        };

        let user_key_2 = ProtonUserKeyModel {
            key_id: "mock_key_id_2".to_string(),
            user_id: "mock_user_id_2".to_string(),
            version: 233,
            private_key: "mock_private_key_here_2".to_string(),
            token: Some("mock_token_2".to_string()),
            fingerprint: Some("151ASYGU".to_string()),
            recovery_secret: None,
            recovery_secret_signature: None,
            active: 1,
            primary: 0,
        };

        // test insert
        let insert_id = proton_user_key_dao.insert(&user_key).await.unwrap();
        assert_eq!(insert_id, 1);
        let insert_id = proton_user_key_dao.insert(&user_key_1).await.unwrap();
        assert_eq!(insert_id, 2);
        let insert_id = proton_user_key_dao.insert(&user_key_2).await.unwrap();
        assert_eq!(insert_id, 3);

        // test query
        let query_item = proton_user_key_dao
            .get_by_key_id("mock_key_id")
            .await
            .unwrap()
            .unwrap();

        assert_eq!(query_item.key_id, "mock_key_id");
        assert_eq!(query_item.user_id, "mock_user_id");
        assert_eq!(query_item.version, 233);
        assert_eq!(query_item.private_key, "mock_private_key_here");
        assert_eq!(query_item.token, Some("mock_token".to_string()));
        assert_eq!(query_item.fingerprint, Some("FTS721AVC2US".to_string()));
        assert!(query_item.recovery_secret.is_none());
        assert!(query_item.recovery_secret_signature.is_none());
        assert_eq!(query_item.primary, 1);

        // test query
        let keys = proton_user_key_dao
            .get_all_by_user_id("mock_user_id")
            .await
            .unwrap();
        assert_eq!(keys.len(), 2);
        let keys = proton_user_key_dao.get_all().await.unwrap();
        assert_eq!(keys.len(), 3);
        let keys = proton_user_key_dao
            .get_all_by_user_id("mock_user_id123")
            .await
            .unwrap();
        assert_eq!(keys.len(), 0);

        // Test updating the key
        let mut updated_key = user_key.clone();
        updated_key.private_key = "updated_private_key".to_string();
        proton_user_key_dao.update(&updated_key).await.unwrap();
        let updated_query = proton_user_key_dao
            .get_by_key_id("mock_key_id")
            .await
            .unwrap()
            .unwrap();
        assert_eq!(updated_query.private_key, "updated_private_key");

        // Test getting all keys
        let all_keys = proton_user_key_dao.get_all().await.unwrap();
        assert_eq!(all_keys.len(), 3);

        let mut user_key_4 = ProtonUserKeyModel {
            key_id: "mock_key_id_4".to_string(),
            user_id: "mock_user_id".to_string(),
            version: 444,
            private_key: "mock_private_key_here_4".to_string(),
            token: Some("mock_token_4".to_string()),
            fingerprint: Some("151ASYGU".to_string()),
            recovery_secret: None,
            recovery_secret_signature: None,
            active: 1,
            primary: 0,
        };
        let upsert_result = proton_user_key_dao
            .upsert(&user_key_4)
            .await
            .unwrap()
            .unwrap();
        assert_eq!(upsert_result.key_id, "mock_key_id_4".to_string());
        assert_eq!(upsert_result.user_id, "mock_user_id".to_string());
        let all_keys = proton_user_key_dao
            .get_all_by_user_id("mock_user_id")
            .await
            .unwrap();
        assert_eq!(all_keys.len(), 3);

        user_key_4.private_key = "updated_private_key".to_string();
        let upsert_result = proton_user_key_dao
            .upsert(&user_key_4)
            .await
            .unwrap()
            .unwrap();
        assert_eq!(upsert_result.private_key, "updated_private_key");
        let all_keys = proton_user_key_dao
            .get_all_by_user_id("mock_user_id")
            .await
            .unwrap();
        assert_eq!(all_keys.len(), 3);
        user_key_4.key_id = "this_is_no_key_in_db".to_string();
        let upsert_result = proton_user_key_dao.update(&user_key_4).await;
        assert!(upsert_result.is_err());
    }
}

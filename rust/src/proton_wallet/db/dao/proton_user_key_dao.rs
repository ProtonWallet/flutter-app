use crate::proton_wallet::db::database::error::DatabaseError;
use crate::proton_wallet::db::database::{
    database::BaseDatabase, proton_user_key::ProtonUserKeyDatabase,
};
use crate::proton_wallet::db::model::proton_user_key_model::ProtonUserKeyModel;
use rusqlite::{params, Connection, Result};
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Debug)]
pub struct ProtonUserKeyDao {
    conn: Arc<Mutex<Connection>>,
    pub database: ProtonUserKeyDatabase,
}

impl ProtonUserKeyDao {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        let database = ProtonUserKeyDatabase::new(conn.clone());
        Self { conn, database }
    }
}

impl ProtonUserKeyDao {
    pub async fn insert(&self, item: &ProtonUserKeyModel) -> Result<u32> {
        let conn = self.conn.lock().await;
        let result: std::result::Result<usize, rusqlite::Error> = conn.execute(
            "INSERT INTO user_keys_table (key_id, user_id, version, private_key, token, fingerprint, recovery_secret, recovery_secret_signature, 'primary') 
            VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)",
            params![
                item.key_id,
                item.user_id,
                item.version,
                item.private_key,
                item.token,
                item.fingerprint,
                item.recovery_secret,
                item.recovery_secret_signature,
                item.primary,
            ]
        );
        match result {
            Ok(_) => Ok(conn.last_insert_rowid() as u32),
            Err(e) => {
                eprintln!("Something went wrong: {}", e);
                Err(e)
            }
        }
    }

    pub async fn get_all(&self) -> Result<Vec<ProtonUserKeyModel>> {
        self.database.get_all().await
    }

    pub async fn get_all_by_user_id(
        &self,
        user_id: &str,
    ) -> Result<Vec<ProtonUserKeyModel>, DatabaseError> {
        self.database.get_all_by_column_id("user_id", user_id).await
    }

    pub async fn get_by_key_id(
        &self,
        key_id: &str,
    ) -> Result<Option<ProtonUserKeyModel>, DatabaseError> {
        self.database.get_by_column_id("key_id", key_id).await
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::{
        dao::proton_user_key_dao::ProtonUserKeyDao,
        model::proton_user_key_model::ProtonUserKeyModel,
    };
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    // #[test]
    // #[ignore]
    // fn test_proton_user_key_dao_from_local_file() {
    //     // open existing database from path
    //     let conn_arc = Arc::new(Mutex::new(
    //         Connection::open("C:\\Users\\will.hsu\\Documents\\databases\\drift_proton_wallet_db")
    //             .unwrap(),
    //     ));

    //     let proton_user_key_dao = ProtonUserKeyDao::new(conn_arc).unwrap();
    //     let user_keys = proton_user_key_dao.get_all().unwrap();
    //     assert_eq!(user_keys.len(), 1);
    //     assert_eq!(user_keys[0].key_id, "54DY3FZ-inMbCA6beQINReu6ziXMErdTiKgmCvATLXJtNGQx9BNo8Iggbgk5IKAXhBOrEWWeq5YcJA6pCvOTDQ==");

    //     let user_keys = proton_user_key_dao.get_all_by_user_id("vJxErOgAzrqjwPfvjlhAoDVPoXbDl2URUzd15JcQNwggW6bkwd70KNWozrMpV_d21FITkNqnMAY5WRxwAGclng==").unwrap();
    //     assert_eq!(user_keys.len(), 1);
    //     assert_eq!(user_keys[0].key_id, "54DY3FZ-inMbCA6beQINReu6ziXMErdTiKgmCvATLXJtNGQx9BNo8Iggbgk5IKAXhBOrEWWeq5YcJA6pCvOTDQ==");

    //     let user_keys = proton_user_key_dao.get_all_by_user_id("123").unwrap();
    //     assert_eq!(user_keys.len(), 0);

    //     let user_key = proton_user_key_dao.get_by_key_id("54DY3FZ-inMbCA6beQINReu6ziXMErdTiKgmCvATLXJtNGQx9BNo8Iggbgk5IKAXhBOrEWWeq5YcJA6pCvOTDQ==").unwrap();
    //     assert_eq!(user_key.is_none(), false);

    //     let user_key = proton_user_key_dao.get_by_key_id("123").unwrap();
    //     assert_eq!(user_key.is_none(), true);
    // }

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
                'primary' INTEGER NOT NULL, 
                PRIMARY KEY (key_id, user_id))
                "#,
                [],
            );
        }
        let proton_user_key_dao = ProtonUserKeyDao::new(conn_arc);
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
        assert_eq!(query_item.recovery_secret.is_none(), true);
        assert_eq!(query_item.recovery_secret_signature.is_none(), true);
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
    }
}

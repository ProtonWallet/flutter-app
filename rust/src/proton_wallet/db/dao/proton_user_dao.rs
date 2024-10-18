use log::error;
use rusqlite::{params, Connection};
use std::sync::Arc;
use tokio::sync::Mutex;

use crate::proton_wallet::db::{
    database::{database::BaseDatabase, proton_user::ProtonUserDatabase},
    model::proton_user_model::ProtonUserModel,
    Result,
};

#[derive(Debug)]
pub struct ProtonUserDao {
    conn: Arc<Mutex<Connection>>,
    pub database: ProtonUserDatabase,
}

impl ProtonUserDao {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        let database = ProtonUserDatabase::new(conn.clone());
        Self { conn, database }
    }
}

impl ProtonUserDao {
    pub async fn insert(&self, item: &ProtonUserModel) -> Result<u32> {
        let conn = self.conn.lock().await;
        let result: std::result::Result<usize, rusqlite::Error> = conn.execute(
            "INSERT INTO users_table (user_id, name, used_space, currency, credit, create_time, max_space, max_upload, role, private, subscribed, services, delinquent, organization_private_key, email, display_name) 
            VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16)",
            params![
                item.user_id,
                item.name,
                item.used_space,
                item.currency,
                item.credit,
                item.create_time,
                item.max_space,
                item.max_upload,
                item.role,
                item.private,
                item.subscribed,
                item.services,
                item.delinquent,
                item.organization_private_key,
                item.email,
                item.display_name
            ]
        );
        match result {
            Ok(_) => Ok(conn.last_insert_rowid() as u32),
            Err(e) => {
                error!("Something went wrong: {}", e);
                Err(e.into())
            }
        }
    }

    pub async fn get_all(&self) -> Result<Vec<ProtonUserModel>> {
        self.database.get_all().await
    }

    pub async fn get_by_user_id(&self, user_id: &str) -> Result<Option<ProtonUserModel>> {
        self.database.get_by_column_id("user_id", user_id).await
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::{
        dao::proton_user_dao::ProtonUserDao, model::proton_user_model::ProtonUserModel,
    };
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    #[ignore]
    async fn test_proton_user_dao_from_local_file() {
        // open existing database from path
        let conn_arc = Arc::new(Mutex::new(
            Connection::open("drift_proton_wallet_db").unwrap(),
        ));

        let proton_user_dao = ProtonUserDao::new(conn_arc);
        let users = proton_user_dao.get_all().await.unwrap();
        assert_eq!(users.len(), 1);
        assert_eq!(users[0].name, "proton.wallet.test");

        let user = proton_user_dao.get_by_user_id("vJxErOgAzrqjwPfvjlhAoDVPoXbDl2URUzd15JcQNwggW6bkwd70KNWozrMpV_d21FITkNqnMAY5WRxwAGclng==").await.unwrap();
        assert!(user.is_some());

        let user = proton_user_dao.get_by_user_id("123").await.unwrap();
        assert!(user.is_none());
    }

    #[tokio::test]
    async fn test_proton_user_dao() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        {
            // create table
            let conn_arc_cp = Arc::clone(&conn_arc);
            let conn = conn_arc_cp.lock().await;
            let _ = conn.execute(
                r#"
                CREATE TABLE IF NOT EXISTS users_table (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
                user_id TEXT NOT NULL, 
                name TEXT NOT NULL, 
                used_space INTEGER NOT NULL, 
                currency TEXT NOT NULL, 
                credit INTEGER NOT NULL, 
                create_time INTEGER NOT NULL, 
                max_space INTEGER NOT NULL, 
                max_upload INTEGER NOT NULL, 
                role INTEGER NOT NULL, 
                private INTEGER NOT NULL, 
                subscribed INTEGER NOT NULL, 
                services INTEGER NOT NULL, 
                delinquent INTEGER NOT NULL, 
                organization_private_key TEXT NULL, 
                email TEXT NULL, 
                display_name TEXT NULL);
                "#,
                [],
            );
        }
        let proton_user_dao = ProtonUserDao::new(conn_arc);
        let users = proton_user_dao.get_all().await.unwrap();
        assert_eq!(users.len(), 0);

        let user = ProtonUserModel {
            id: 0,
            user_id: "mock_user_id".to_string(),
            name: "test proton user".to_string(),
            used_space: 6666,
            currency: "CHF".to_string(),
            credit: 168,
            create_time: 55688,
            max_space: 9999,
            max_upload: 1234,
            role: 10,
            private: 1,
            subscribed: 0,
            services: 12,
            delinquent: 0,
            organization_private_key: None,
            email: Some("test@example.com".to_string()),
            display_name: Some("Test User".to_string()),
        };

        // test insert
        let insert_id = proton_user_dao.insert(&user).await.unwrap();
        assert_eq!(insert_id, 1);

        // test query
        let query_item = proton_user_dao
            .get_by_user_id("mock_user_id")
            .await
            .unwrap()
            .unwrap();

        assert_eq!(query_item.id, 1);
        assert_eq!(query_item.user_id, "mock_user_id");
        assert_eq!(query_item.name, "test proton user");
        assert_eq!(query_item.used_space, 6666);
        assert_eq!(query_item.currency, "CHF");
        assert_eq!(query_item.credit, 168);
        assert_eq!(query_item.create_time, 55688);
        assert_eq!(query_item.max_space, 9999);
        assert_eq!(query_item.max_upload, 1234);
        assert_eq!(query_item.role, 10);
        assert_eq!(query_item.private, 1);
        assert_eq!(query_item.subscribed, 0);
        assert_eq!(query_item.services, 12);
        assert_eq!(query_item.delinquent, 0);
        assert!(query_item.organization_private_key.is_none());
        assert!(query_item.email.is_some());
        assert_eq!(query_item.display_name, Some("Test User".to_string()));
    }
}

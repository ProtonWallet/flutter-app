use rusqlite::Result;

pub trait Dao<T> {
    fn insert(&self, item: &T) -> Result<u32>;
    fn get(&self, id: i32) -> Result<Option<T>>;
    fn get_by_server_id(&self, server_id: &str) -> Result<Option<T>>;
    fn get_all(&self) -> Result<Vec<T>>;
    fn update(&self, item: &T) -> Result<Option<T>>;
    fn delete(&self, id: i32) -> Result<()>;
    fn delete_by_server_id(&self, server_id: &str) -> Result<()>;
}

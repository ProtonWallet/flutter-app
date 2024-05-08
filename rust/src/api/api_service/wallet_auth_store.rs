// use std::sync::Arc;

// use flutter_rust_bridge::{frb, DartFnFuture};

// // pub use crate::auth_store::DartCallback;
// use crate::auth_store::WalletDataAuthStore;

// // type DartFnFuture<T> = Pin<Box<dyn Future<Output = T> + Send>>;

// // Fn(String, String) -> DartFnFuture<bool>

// // static GLOBAL_CALLBACK: Lazy<RwLock<Option<Arc<DartCallback>>>> = Lazy::new(|| RwLock::new(None));

// // pub async fn set_global_callback(dart_callback: Arc<DartCallback>) {
//     // let mut callback_guard = GLOBAL_CALLBACK.write().await;
//     // *callback_guard = Some(dart_callback);
// // }

// // pub async fn get_global_callback() -> Option<Arc<DartCallback>> {
// //     // let callback_guard = GLOBAL_CALLBACK.read().await;
// //     // callback_guard.clone()
// // }

use std::{
    future::Future,
    pin::Pin,
    sync::{Arc, Mutex},
};

use flutter_rust_bridge::frb;

use crate::auth_store::WalletDataAuthStore;

pub struct WalletAuthStore {
    pub inner: WalletDataAuthStore,
}
// // impl Default for WalletAuthStore {
// //     fn default() -> Self {
// //         Self::new()
// //     }
// // }

// impl WalletAuthStore {

//     pub fn new(dart_callback: impl Fn(String, String) -> DartFnFuture<bool>) -> Self {
//         Self {
//             inner: WalletDataAuthStore::new("", dart_callback),//, delegate),
//         }
//     }
//     pub async fn rust_function(dart_callback: impl Fn(String, String) -> DartFnFuture<bool>) {
//         dart_callback("Tom".to_owned(), "bob".to_owned()).await; // Will get `Hello, Tom!`
//     }
// }

// pub type DartFnFuture<T> = Pin<Box<dyn Future<Output = T> + Send + Sync>>;
pub type DartFnFuture<T> = Pin<Box<dyn Future<Output = T> + Send + 'static>>;
pub type DartCallback = dyn Fn(String) -> DartFnFuture<String> + Send + Sync;

lazy_static::lazy_static! {
    static ref GLOBAL_CALLBACK: Mutex<Option<Arc<DartCallback>>> = Mutex::new(None);
}

// #[frb(sync)]
pub fn set_dart_callback(callback: impl Fn(String) -> DartFnFuture<String> + Send + Sync + 'static) {
    let mut cb = GLOBAL_CALLBACK.lock().unwrap();
    *cb = Some(Arc::new(callback));
}

pub(crate) async fn call_dart_callback(message: String) -> Result<String, String> {
    let cb = GLOBAL_CALLBACK.lock().unwrap();
    if let Some(callback) = cb.as_ref() {
        Ok(callback(message).await)
    } else {
        Err("Callback not set".to_string())
    }
}

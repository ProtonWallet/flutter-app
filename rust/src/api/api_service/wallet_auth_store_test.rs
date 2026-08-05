use std::sync::{
    atomic::{AtomicBool, Ordering},
    Arc, Mutex as StdMutex,
};

use andromeda_api::{Auth, Store, Tokens, WalletAuthStore};

use super::wallet_auth_store::test_exports::{
    auth_session_changed, global_session_dart_callback, new_callback_store,
    set_api_client_initializing,
};

static TEST_LOCK: tokio::sync::Mutex<()> = tokio::sync::Mutex::const_new(());

fn test_auth(access: &str, refresh: &str) -> Auth {
    Auth::internal(
        "user_id",
        "session_uid",
        Tokens::access(access, refresh, ["wallet", "account"]),
    )
}

async fn wait_for<F: Fn() -> bool>(predicate: F) {
    for _ in 0..50 {
        if predicate() {
            return;
        }
        tokio::time::sleep(std::time::Duration::from_millis(10)).await;
    }
    panic!("condition not met within timeout");
}

#[test]
fn auth_session_changed_detects_token_updates() {
    let previous = test_auth("access_a", "refresh_a");
    let updated_access = test_auth("access_b", "refresh_a");
    let updated_refresh = test_auth("access_a", "refresh_b");
    let unchanged = test_auth("access_a", "refresh_a");

    assert!(auth_session_changed(&previous, &updated_access));
    assert!(auth_session_changed(&previous, &updated_refresh));
    assert!(!auth_session_changed(&previous, &unchanged));
    assert!(!auth_session_changed(&previous, &Auth::None));
}

#[tokio::test]
async fn set_auth_through_callback_store_invokes_registered_callback() {
    let _guard = TEST_LOCK.lock().await;
    set_api_client_initializing(false);

    let called = Arc::new(AtomicBool::new(false));
    let called_for_callback = called.clone();

    {
        let mut cb = global_session_dart_callback().lock().await;
        *cb = Some(Arc::new(move |_session| {
            let called = called_for_callback.clone();
            Box::pin(async move {
                called.store(true, Ordering::SeqCst);
                "Reply from test callback".to_string()
            })
        }));
    }

    let auth = test_auth("access_a", "refresh_a");
    let store =
        WalletAuthStore::from_env_str("prod".to_string(), Arc::new(StdMutex::new(auth.clone())));
    let mut callback_store = new_callback_store(store);

    callback_store
        .set_auth(&(), test_auth("access_b", "refresh_a"))
        .await
        .unwrap();

    wait_for(|| called.load(Ordering::SeqCst)).await;

    let mut cb = global_session_dart_callback().lock().await;
    *cb = None;
}

#[tokio::test]
async fn set_all_auth_through_callback_store_invokes_registered_callback() {
    let _guard = TEST_LOCK.lock().await;
    set_api_client_initializing(false);

    let called = Arc::new(AtomicBool::new(false));
    let called_for_callback = called.clone();

    {
        let mut cb = global_session_dart_callback().lock().await;
        *cb = Some(Arc::new(move |_session| {
            let called = called_for_callback.clone();
            Box::pin(async move {
                called.store(true, Ordering::SeqCst);
                "Reply from test callback".to_string()
            })
        }));
    }

    let auth = test_auth("access_a", "refresh_a");
    let store =
        WalletAuthStore::from_env_str("prod".to_string(), Arc::new(StdMutex::new(auth.clone())));
    let mut callback_store = new_callback_store(store);

    let mut auth_map = std::collections::HashMap::new();
    auth_map.insert((), test_auth("access_b", "refresh_a"));
    callback_store.set_all_auth(auth_map).await.unwrap();

    wait_for(|| called.load(Ordering::SeqCst)).await;

    let mut cb = global_session_dart_callback().lock().await;
    *cb = None;
}

#[tokio::test]
async fn set_auth_during_api_client_init_does_not_invoke_callback() {
    let _guard = TEST_LOCK.lock().await;

    let called = Arc::new(AtomicBool::new(false));
    let called_for_callback = called.clone();

    {
        let mut cb = global_session_dart_callback().lock().await;
        *cb = Some(Arc::new(move |_session| {
            let called = called_for_callback.clone();
            Box::pin(async move {
                called.store(true, Ordering::SeqCst);
                "Reply from test callback".to_string()
            })
        }));
    }

    set_api_client_initializing(true);
    let auth = test_auth("access_a", "refresh_a");
    let store =
        WalletAuthStore::from_env_str("prod".to_string(), Arc::new(StdMutex::new(auth.clone())));
    let mut callback_store = new_callback_store(store);

    callback_store
        .set_auth(&(), test_auth("access_b", "refresh_a"))
        .await
        .unwrap();

    tokio::time::sleep(std::time::Duration::from_millis(100)).await;
    assert!(!called.load(Ordering::SeqCst));

    set_api_client_initializing(false);
    let mut cb = global_session_dart_callback().lock().await;
    *cb = None;
}

mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */

/// frb interface
pub mod api;

pub mod proton_bdk;

pub mod common;
pub mod proton_api;
pub mod proton_wallet;
pub mod srp;

pub mod ldk;
pub mod mocks;

pub use crate::api::errors::BridgeError;
pub use crate::proton_api::*;

pub use andromeda_api::wallet::CreateWalletAccountRequestBody;

/// Android JNI hook kept for backwards compatibility with the Kotlin plugin.
/// muon 2.x uses rustls-platform-verifier and no longer requires java_init.
#[cfg(target_os = "android")]
#[no_mangle]
pub extern "system" fn Java_me_proton_wallet_android_WalletFlutterPlugin_init_1android(
    _env: jni::sys::JNIEnv,
    _class: jni::sys::jclass,
    _ctx: jni::sys::jobject,
) -> jni::sys::jboolean {
    tracing::info!("init_android: no-op (muon 2.x)");
    1
}

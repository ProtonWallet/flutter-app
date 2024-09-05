mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */

/// frb interface
pub mod api;

// pub mod bdk;
pub mod common;
// pub mod ldk;
pub mod proton_api;
pub mod srp;
// pub mod utilities;
pub mod proton_wallet;

pub use crate::common::errors::BridgeError;
pub use crate::proton_api::*;

pub use andromeda_api::wallet::CreateWalletAccountRequestBody;

/// this part is for android jni env initialization. muon reqires
#[cfg(target_os = "android")]
use {
    andromeda_api::{jboolean, JClass, JNIEnv, JObject},
    log::info,
};

#[cfg(target_os = "android")]
#[no_mangle]
pub extern "system" fn Java_me_proton_wallet_android_WalletFlutterPlugin_init_1android(
    env: JNIEnv,
    class: JClass,
    ctx: JObject,
) -> jboolean {
    info!("init_android called from rust lib.rs file.");
    return andromeda_api::init_android(env, class, ctx);
}

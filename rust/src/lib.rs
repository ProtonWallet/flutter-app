pub mod api;
pub mod bdk;
pub mod bdk_common;
mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
pub mod ldk;
pub mod proton_api;
pub mod utilities;
pub use andromeda_api::wallet::CreateWalletAccountRequestBody;

pub use crate::bdk::key::Mnemonic;
pub use crate::proton_api::*;

#[cfg(target_os = "android")]
use {
    andromeda_api::{jboolean, JClass, JNIEnv, JObject},
    // mylib::setup_android,
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

pub use andromeda_api::transaction::BroadcastMessage;
use flutter_rust_bridge::frb;
use std::collections::HashMap;

#[frb(mirror(BroadcastMessage))]
#[allow(non_snake_case)]
pub struct _BroadcastMessage {
    pub DataPacket: String,
    pub KeyPackets: HashMap<String, String>,
}

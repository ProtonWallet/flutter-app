pub use andromeda_api::transaction::MempoolInfo;
use flutter_rust_bridge::frb;

#[frb(mirror(MempoolInfo))]
#[allow(non_snake_case)]
pub struct _MempoolInfo {
    pub Loaded: u8,
    pub Size: u32,
    pub Bytes: u32,
    pub Usage: u32,
    pub MaxMempool: u32,
    pub MempoolMinFee: f32,
    pub MinRelayTxFee: f32,
    pub IncrementalRelayFee: f32,
    pub UnbroadcastCount: u8,
    pub FullRbf: u8,
}

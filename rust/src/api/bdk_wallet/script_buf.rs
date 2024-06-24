// script_buf.rs
use flutter_rust_bridge::frb;

use andromeda_bitcoin::ScriptBuf as BdkScriptBuf;

#[derive(Debug, Clone, PartialOrd, Ord, PartialEq, Eq, Hash)]
pub struct FrbScriptBuf {
    pub(crate) inner: BdkScriptBuf,
}

impl FrbScriptBuf {
    #[frb(sync)]
    pub fn new(raw_output_script: Vec<u8>) -> FrbScriptBuf {
        let script = BdkScriptBuf::from(raw_output_script);
        FrbScriptBuf { inner: script }
    }
}

impl FrbScriptBuf {
    #[frb(sync)]
    pub fn to_bytes(&self) -> Vec<u8> {
        self.inner.to_bytes()
    }
}

impl From<BdkScriptBuf> for FrbScriptBuf {
    fn from(script: BdkScriptBuf) -> Self {
        FrbScriptBuf { inner: script }
    }
}

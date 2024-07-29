pub use andromeda_api::discovery_content::Content;
use flutter_rust_bridge::frb;

#[frb(mirror(Content))]
#[allow(non_snake_case)]
pub struct _Content {
    pub Title: String,
    pub Link: String,
    pub Description: String,
    pub PubDate: i64,
    pub Author: String,
    pub Category: String,
}

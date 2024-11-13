// payment_link.rs
use andromeda_bitcoin::payment_link::PaymentLink;
use andromeda_common::Network;
use flutter_rust_bridge::frb;

use crate::BridgeError;

#[derive(Debug, PartialEq, Clone)]
pub struct FrbPaymentLink {
    pub(crate) inner: PaymentLink,
}

impl FrbPaymentLink {
    #[frb(sync)]
    pub fn to_string(&self) -> String {
        self.inner.to_string()
    }

    #[frb(sync)]
    pub fn to_uri(&self) -> String {
        self.inner.to_uri()
    }

    #[frb(sync)]
    pub fn to_address(&self) -> String {
        self.inner.to_address_string()
    }

    #[frb(sync)]
    pub fn try_parse(str: String, network: Network) -> Result<FrbPaymentLink, BridgeError> {
        let inner = PaymentLink::try_parse(str, network.into())?;

        Ok(FrbPaymentLink { inner })
    }
}

impl From<PaymentLink> for FrbPaymentLink {
    fn from(inner: PaymentLink) -> Self {
        FrbPaymentLink { inner }
    }
}

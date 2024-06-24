// payment_link.rs
use flutter_rust_bridge::frb;

use andromeda_bitcoin::payment_link::PaymentLink;
use andromeda_common::Network;

use crate::BridgeError;

#[derive(Debug, PartialEq, Clone)]
pub struct FrbPaymentLink {
    inner: PaymentLink,
}

// pub enum PaymentLinkKind {
//     BitcoinAddress,
//     BitcoinURI,
//     LightningURI,
//     UnifiedURI,
// }
// pub struct OnchainPaymentLink {
//     pub address: Option<String>,
//     pub amount: Option<u64>,
//     pub message: Option<String>,
//     pub label: Option<String>,
// }

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
    pub fn try_parse(str: String, network: Network) -> Result<FrbPaymentLink, BridgeError> {
        let inner = PaymentLink::try_parse(str, network.into())?;

        Ok(FrbPaymentLink { inner })
    }

    //     pub fn get_kind(&self) -> PaymentLinkKind {
    //         match self.inner {
    //             PaymentLink::BitcoinAddress(_) => PaymentLinkKind::BitcoinAddress,
    //             PaymentLink::BitcoinURI { .. } => PaymentLinkKind::BitcoinURI,
    //             PaymentLink::LightningURI { .. } => PaymentLinkKind::LightningURI,
    //             PaymentLink::UnifiedURI { .. } => PaymentLinkKind::UnifiedURI,
    //         }
    //     }
    //     pub fn assume_onchain(&self) -> OnchainPaymentLink {
    //         match self.inner.clone() {
    //             PaymentLink::BitcoinAddress(address) => OnchainPaymentLink {
    //                 address: Some(address.to_string()),
    //                 ..OnchainPaymentLink::default()
    //             },
    //             PaymentLink::BitcoinURI {
    //                 address,
    //                 amount,
    //                 label,
    //                 message,
    //             } => OnchainPaymentLink {
    //                 address: Some(address.to_string()),
    //                 amount,
    //                 label,
    //                 message,
    //             },
    //             PaymentLink::LightningURI { .. } => OnchainPaymentLink::default(),
    //             PaymentLink::UnifiedURI { .. } => OnchainPaymentLink::default(),
    //         }
    //     }
}

impl From<PaymentLink> for FrbPaymentLink {
    fn from(inner: PaymentLink) -> Self {
        FrbPaymentLink { inner }
    }
}

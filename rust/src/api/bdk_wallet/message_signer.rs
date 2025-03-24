use crate::{api::bdk_wallet::account::FrbAccount, BridgeError};
use andromeda_bitcoin::{message_signer::MessageSigner, SigningType};
use flutter_rust_bridge::frb;

#[derive(Clone, Copy)]
pub struct FrbMessageSigner(MessageSigner);

impl FrbMessageSigner {
    #[frb(sync)]
    pub fn new() -> Self {
        Self(MessageSigner {})
    }
}

impl FrbMessageSigner {
    pub async fn sign_message(
        &self,
        account: &FrbAccount,
        signing_type: SigningType,
        message: &str,
        btc_address: &str,
    ) -> Result<String, BridgeError> {
        let account_inner = account.get_inner();
        Ok(self
            .0
            .sign_message(&account_inner, message, signing_type, btc_address)
            .await?)
    }

    pub async fn verify_message(
        &self,
        account: &FrbAccount,
        message: &str,
        signature: &str,
        btc_address: &str,
    ) -> Result<(), BridgeError> {
        let account_inner = account.get_inner();
        Ok(self
            .0
            .verify_message(&account_inner, message, signature, btc_address)
            .await?)
    }
}

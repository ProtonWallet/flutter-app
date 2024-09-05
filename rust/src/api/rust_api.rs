// rust_api.rs
use super::bdk_wallet::address::FrbAddress;
use super::bdk_wallet::blockchain::FrbBlockchainClient;
use super::bdk_wallet::derivation_path::FrbDerivationPath;
use super::bdk_wallet::mnemonic::FrbMnemonic;
use super::bdk_wallet::script_buf::FrbScriptBuf;
use super::proton_api::retrieve_proton_api;

use crate::BridgeError;
use andromeda_common::Network;

use andromeda_bitcoin::WordCount;

pub struct Api {}
impl Api {
    //========Blockchain==========

    /// create esplora blockchain with proton api
    pub fn create_esplora_blockchain_with_api(// config: EsploraConfig,
    ) -> Result<FrbBlockchainClient, BridgeError> {
        let proton_api = retrieve_proton_api()?;
        let blockchain = FrbBlockchainClient::new(proton_api)?;
        Ok(blockchain)
    }

    //==============Derivation Path ==========
    pub async fn create_derivation_path(path: String) -> Result<FrbDerivationPath, BridgeError> {
        FrbDerivationPath::new(&path)
    }

    //============ Script Class===========
    pub fn create_script(raw_output_script: Vec<u8>) -> Result<FrbScriptBuf, BridgeError> {
        Ok(FrbScriptBuf::new(raw_output_script))
    }

    //================Address============
    pub fn create_address(address: String, network: Network) -> Result<FrbAddress, BridgeError> {
        FrbAddress::new(address, network)
    }
    pub fn address_from_script(
        script: FrbScriptBuf,
        network: Network,
    ) -> Result<FrbAddress, BridgeError> {
        FrbAddress::from_script(script, network)
    }

    ///================== Mnemonic ==========
    pub fn generate_seed_from_word_count(word_count: WordCount) -> Result<String, BridgeError> {
        let mnemonic = FrbMnemonic::new(word_count)?;
        Ok(mnemonic.as_string())
    }
    pub fn generate_seed_from_string(mnemonic: String) -> Result<String, BridgeError> {
        Ok(FrbMnemonic::from_string(mnemonic)?.as_string())
    }
}

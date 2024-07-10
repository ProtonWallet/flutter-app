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

    //========TxBuilder==========
    // #[allow(clippy::too_many_arguments)]
    // pub fn tx_builder_finish(
    //     wallet_id: String,
    //     recipients: Vec<ScriptAmount>,
    //     utxos: Vec<OutPoint>,
    //     foreign_utxo: Option<(OutPoint, String, usize)>,
    //     unspendable: Vec<OutPoint>,
    //     change_policy: ChangeSpendPolicy,
    //     manually_selected_only: bool,
    //     fee_rate: Option<f32>,
    //     fee_absolute: Option<u64>,
    //     drain_wallet: bool,
    //     drain_to: Option<FrbScriptBuf>,
    //     rbf: Option<RbfValue>,
    //     data: Vec<u8>,
    // ) -> Result<(String, TransactionDetails), Error> {
    //     RUNTIME.read().unwrap().clone().block_on(async {
    //         let binding = Wallet::retrieve_wallet(wallet_id);
    //         let binding = binding.get_wallet().await;

    //         let mut tx_builder = binding.build_tx();

    //         for e in recipients {
    //             tx_builder.add_recipient(e.script.into(), e.amount);
    //         }
    //         tx_builder.change_policy(change_policy.into());

    //         if !utxos.is_empty() {
    //             let bdk_utxos: Vec<BdkOutPoint> = utxos.iter().map(BdkOutPoint::from).collect();
    //             let utxos: &[BdkOutPoint] = &bdk_utxos;
    //             tx_builder.add_utxos(utxos).unwrap();
    //         }
    //         if !unspendable.is_empty() {
    //             let bdk_unspendable: Vec<BdkOutPoint> =
    //                 unspendable.iter().map(BdkOutPoint::from).collect();
    //             tx_builder.unspendable(bdk_unspendable);
    //         }
    //         if manually_selected_only {
    //             tx_builder.manually_selected_only();
    //         }
    //         if let Some(sat_per_vb) = fee_rate {
    //             tx_builder.fee_rate(bdk::FeeRate::from_sat_per_vb(sat_per_vb));
    //         }
    //         if let Some(fee_amount) = fee_absolute {
    //             tx_builder.fee_absolute(fee_amount);
    //         }
    //         if drain_wallet {
    //             tx_builder.drain_wallet();
    //         }
    //         if let Some(script_) = drain_to {
    //             tx_builder.drain_to(script_.into());
    //         }
    //         if let Some(f_utxo) = foreign_utxo {
    //             let input = to_input(f_utxo.1);
    //             tx_builder
    //                 .add_foreign_utxo(f_utxo.0.borrow().into(), input, f_utxo.2)
    //                 .expect("Error adding foreign_utxo!");
    //         }
    //         if let Some(rbf) = &rbf {
    //             match rbf {
    //                 RbfValue::RbfDefault => {
    //                     tx_builder.enable_rbf();
    //                 }
    //                 RbfValue::Value(nsequence) => {
    //                     tx_builder.enable_rbf_with_sequence(Sequence(nsequence.to_owned()));
    //                 }
    //             }
    //         }
    //         if !data.is_empty() {
    //             let mut buf = PushBytesBuf::new();
    //             buf.extend_from_slice(data.as_slice())
    //                 .map_err(|e| Error::Psbt(e.to_string()))?;

    //             tx_builder.add_data(&buf.as_push_bytes());
    //         }

    //         match tx_builder.finish() {
    //             Ok(e) => Ok((
    //                 PartiallySignedTransaction {
    //                     internal: Mutex::new(e.0),
    //                 }
    //                 .serialize()
    //                 .await,
    //                 TransactionDetails::from(&e.1),
    //             )),
    //             Err(e) => Err(e.into()),
    //         }
    //     })
    // }

    //========BumpFeeTxBuilder==========
    // pub fn bump_fee_tx_builder_finish(
    //     txid: String,
    //     fee_rate: f32,
    //     allow_shrinking: Option<String>,
    //     wallet_id: String,
    //     enable_rbf: bool,
    //     n_sequence: Option<u32>,
    // ) -> Result<(String, TransactionDetails), Error> {
    //     RUNTIME.read().unwrap().clone().block_on(async {
    //         let txid = Txid::from_str(txid.as_str()).unwrap();
    //         let binding = Wallet::retrieve_wallet(wallet_id);
    //         let bdk_wallet = binding.get_wallet().await;

    //         let mut tx_builder = bdk_wallet.build_fee_bump(txid)?;
    //         tx_builder.fee_rate(bdk::FeeRate::from_sat_per_vb(fee_rate));
    //         if let Some(allow_shrinking) = &allow_shrinking {
    //             let address = BdkAddress::from_str(allow_shrinking)
    //                 .map_err(|e| Error::Generic(e.to_string()))
    //                 .unwrap()
    //                 .assume_checked();
    //             let script = address.script_pubkey();
    //             tx_builder.allow_shrinking(script).unwrap();
    //         }
    //         if let Some(n_sequence) = n_sequence {
    //             tx_builder.enable_rbf_with_sequence(Sequence(n_sequence));
    //         }
    //         if enable_rbf {
    //             tx_builder.enable_rbf();
    //         }
    //         match tx_builder.finish() {
    //             Ok(e) => Ok((
    //                 PartiallySignedTransaction {
    //                     internal: Mutex::new(e.0),
    //                 }
    //                 .serialize()
    //                 .await,
    //                 TransactionDetails::from(&e.1),
    //             )),
    //             Err(e) => Err(e.into()),
    //         }
    //     })
    // }

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

    //========Wallet==========
    // pub fn create_wallet(
    //     descriptor: String,
    //     change_descriptor: Option<String>,
    //     network: Network,
    //     // database_config: DatabaseConfig,
    // ) -> Result<String, Error> {
    //     Ok(Wallet::new_wallet(
    //         descriptor,
    //         change_descriptor,
    //         network,
    //         database_config,
    //     )?)
    // }

    // pub async fn get_address(
    //     wallet_id: String,
    //     address_index: AddressIndex,
    // ) -> Result<AddressInfo, Error> {
    //     Ok(Wallet::retrieve_wallet(wallet_id)
    //         .get_address(address_index)
    //         .await?)
    // }
    // pub async fn is_mine(script: FrbScriptBuf, wallet_id: String) -> Result<bool, Error> {
    //     Ok(Wallet::retrieve_wallet(wallet_id)
    //         .is_mine(script.inner.clone())
    //         .await?)
    // }
    // pub async fn get_internal_address(
    //     wallet_id: String,
    //     address_index: AddressIndex,
    // ) -> Result<AddressInfo, Error> {
    //     Ok(Wallet::retrieve_wallet(wallet_id)
    //         .get_internal_address(address_index)
    //         .await?)
    // }
    // pub fn sync_wallet(wallet_id: String, blockchain_id: String) {
    //     warn!("warn sync_wallet: start syncing");
    //     info!("sync_wallet: start syncing");
    //     RUNTIME.read().unwrap().clone().block_on(async {
    //         // Call your async function here.
    //         Wallet::retrieve_wallet(wallet_id)
    //             .sync(Blockchain::retrieve_blockchain(blockchain_id).deref(), None)
    //             .await;
    //     });
    //     info!("sync_wallet: end syncing");
    // }
    // pub async fn get_balance(wallet_id: String) -> Result<Balance, Error> {
    //     Ok(Wallet::retrieve_wallet(wallet_id).get_balance().await?)
    // }
    // pub async fn list_unspent_outputs(wallet_id: String) -> Result<Vec<LocalUtxo>, Error> {
    //     Ok(Wallet::retrieve_wallet(wallet_id).list_unspent().await?)
    // }
    // pub async fn get_transactions(
    //     wallet_id: String,
    //     include_raw: bool,
    // ) -> Result<Vec<TransactionDetails>, Error> {
    //     Ok(Wallet::retrieve_wallet(wallet_id)
    //         .list_transactions(include_raw)
    //         .await?)
    // }
    // pub async fn sign(
    //     wallet_id: String,
    //     psbt_str: String,
    //     sign_options: Option<SignOptions>,
    // ) -> Result<Option<String>, Error> {
    //     let psbt = PartiallySignedTransaction::new(psbt_str)?;
    //     let signed = Wallet::retrieve_wallet(wallet_id)
    //         .sign(&psbt, sign_options.clone())
    //         .await?;
    //     match signed {
    //         true => Ok(Some(psbt.serialize().await)),
    //         false => {
    //             if let Some(sign_option) = sign_options {
    //                 if sign_option.is_multi_sig {
    //                     Ok(Some(psbt.serialize().await))
    //                 } else {
    //                     Ok(None)
    //                 }
    //             } else {
    //                 Ok(None)
    //             }
    //         }
    //     }
    // }
    // pub async fn wallet_network(wallet_id: String) -> Network {
    //     Wallet::retrieve_wallet(wallet_id)
    //         .get_wallet()
    //         .await
    //         .network()
    //         .into()
    // }
    // pub async fn list_unspent(wallet_id: String) -> Result<Vec<LocalUtxo>, Error> {
    //     Ok(Wallet::retrieve_wallet(wallet_id).list_unspent().await?)
    // }
    // /// get the corresponding PSBT Input for a LocalUtxo
    // pub async fn get_psbt_input(
    //     wallet_id: String,
    //     utxo: LocalUtxo,
    //     only_witness_utxo: bool,
    //     psbt_sighash_type: Option<PsbtSigHashType>,
    // ) -> Result<String, Error> {
    //     let input = Wallet::retrieve_wallet(wallet_id)
    //         .get_psbt_input(utxo, only_witness_utxo, psbt_sighash_type)
    //         .await?;
    //     Ok(serde_json::to_string(&input)?)
    // }

    // pub async fn get_descriptor_for_keychain(
    //     wallet_id: String,
    //     keychain: KeychainKind,
    // ) -> Result<(String, Network), Error> {
    //     let wallet = Wallet::retrieve_wallet(wallet_id);
    //     let network: Network = wallet.get_wallet().await.network().into();
    //     match wallet.get_descriptor_for_keychain(keychain).await {
    //         Ok(e) => Ok((e.as_string_private(), network)),
    //         Err(e) => Err(e.into()),
    //     }
    // }

    ///================== Mnemonic ==========
    pub fn generate_seed_from_word_count(word_count: WordCount) -> Result<String, BridgeError> {
        let mnemonic = FrbMnemonic::new(word_count)?;
        Ok(mnemonic.as_string())
    }
    pub fn generate_seed_from_string(mnemonic: String) -> Result<String, BridgeError> {
        Ok(FrbMnemonic::from_string(mnemonic)?.as_string())
    }
}

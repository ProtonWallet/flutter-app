pub use crate::blockchain::{Blockchain, BlockchainConfig};
pub use crate::descriptor::BdkDescriptor;
use crate::error::Error;
use crate::key::{DerivationPath, DescriptorPublicKey, DescriptorSecretKey, Mnemonic};
use crate::psbt::PartiallySignedTransaction;
pub use crate::psbt::Transaction;
use crate::types::{
    to_input, Address, AddressIndex, AddressInfo, Balance, ChangeSpendPolicy, KeychainKind,
    Network, OutPoint, Payload, PsbtSigHashType, RbfValue, Script, ScriptAmount,
    TransactionDetails, TxIn, TxOut, WordCount,
};
pub use crate::wallet::{DatabaseConfig, Wallet};
use bdk::bitcoin::{Address as BdkAddress, OutPoint as BdkOutPoint, Sequence, Txid};
use bdk::keys::DescriptorSecretKey as BdkDescriptorSecretKey;
use lazy_static::lazy_static;
use std::borrow::Borrow;
use std::ops::Deref;
use std::str::FromStr;
use std::sync::{Arc, Mutex, RwLock};

use crate::wallet::{LocalUtxo, SignOptions};

lazy_static! {
    static ref RUNTIME: RwLock<Option<tokio::runtime::Runtime>> = RwLock::new(None);
}
pub struct Api {}
impl Api {
    //========Blockchain==========
    pub fn create_blockchain(config: BlockchainConfig) -> anyhow::Result<String, Error> {
        let blockchain = Blockchain::new(config);
        return match blockchain {
            Ok(e) => Ok(e),
            Err(e) => Err(e.into()),
        };
    }
    pub fn get_height(blockchain_id: String) -> anyhow::Result<u32, Error> {
        return match Blockchain::retrieve_blockchain(blockchain_id).get_height() {
            Ok(e) => Ok(e),
            Err(e) => Err(e.into()),
        };
    }
    pub fn get_blockchain_hash(
        blockchain_height: u32,
        blockchain_id: String,
    ) -> anyhow::Result<String, Error> {
        return match Blockchain::retrieve_blockchain(blockchain_id)
            .get_block_hash(blockchain_height)
        {
            Ok(e) => Ok(e),
            Err(e) => Err(e.into()),
        };
    }
    pub fn estimate_fee(target: u64, blockchain_id: String) -> anyhow::Result<f32, Error> {
        return match Blockchain::retrieve_blockchain(blockchain_id).estimate_fee(target) {
            Ok(e) => Ok(e.as_sat_per_vb()),
            Err(e) => Err(e.into()),
        };
    }
    pub fn broadcast(tx: String, blockchain_id: String) -> anyhow::Result<String, Error> {
        let transaction: Transaction = tx.into();
        return match Blockchain::retrieve_blockchain(blockchain_id).broadcast(transaction) {
            Ok(e) => Ok(e),
            Err(e) => Err(e.into()),
        };
    }

    //=========Transaction===========

    pub fn create_transaction(tx: Vec<u8>) -> anyhow::Result<String, Error> {
        let res = Transaction::new(tx);
        match res {
            Ok(e) => Ok(e.into()),
            Err(e) => Err(e.into()),
        }
    }
    pub fn tx_txid(tx: String) -> anyhow::Result<String, Error> {
        let tx_: Transaction = tx.into();
        Ok(tx_.txid())
    }
    pub fn weight(tx: String) -> u64 {
        let tx_: Transaction = tx.into();
        tx_.weight() as u64
    }
    pub fn size(tx: String) -> u64 {
        let tx_: Transaction = tx.into();
        tx_.size() as u64
    }
    pub fn vsize(tx: String) -> u64 {
        let tx_: Transaction = tx.into();
        tx_.vsize() as u64
    }
    pub fn serialize_tx(tx: String) -> Vec<u8> {
        let tx_: Transaction = tx.into();
        tx_.serialize()
    }
    pub fn is_coin_base(tx: String) -> bool {
        let tx_: Transaction = tx.into();
        tx_.is_coin_base()
    }
    pub fn is_explicitly_rbf(tx: String) -> bool {
        let tx_: Transaction = tx.into();
        tx_.is_explicitly_rbf()
    }
    pub fn is_lock_time_enabled(tx: String) -> bool {
        let tx_: Transaction = tx.into();
        tx_.is_lock_time_enabled()
    }
    pub fn version(tx: String) -> i32 {
        let tx_: Transaction = tx.into();
        tx_.version()
    }
    pub fn lock_time(tx: String) -> u32 {
        let tx_: Transaction = tx.into();
        tx_.lock_time()
    }
    pub fn input(tx: String) -> Vec<TxIn> {
        let tx_: Transaction = tx.into();
        tx_.input()
    }
    pub fn output(tx: String) -> Vec<TxOut> {
        let tx_: Transaction = tx.into();
        tx_.output()
    }

    //========PartiallySignedTransaction==========
    pub fn serialize_psbt(psbt_str: String) -> anyhow::Result<String, Error> {
        let psbt = PartiallySignedTransaction::new(psbt_str);
        return match psbt {
            Ok(e) => Ok(e.serialize()),
            Err(e) => Err(e.into()),
        };
    }
    pub fn psbt_txid(psbt_str: String) -> anyhow::Result<String, Error> {
        let psbt = PartiallySignedTransaction::new(psbt_str);
        return match psbt {
            Ok(e) => Ok(e.txid()),
            Err(e) => Err(e.into()),
        };
    }
    pub fn extract_tx(psbt_str: String) -> anyhow::Result<String, Error> {
        let psbt = PartiallySignedTransaction::new(psbt_str);
        return match psbt {
            Ok(e) => Ok(e.extract_tx().into()),
            Err(e) => Err(e.into()),
        };
    }
    pub fn psbt_fee_rate(psbt_str: String) -> Option<f32> {
        let psbt = PartiallySignedTransaction::new(psbt_str);
        match psbt.unwrap().fee_rate() {
            None => None,
            Some(e) => Some(e.as_sat_per_vb()),
        }
    }
    pub fn psbt_fee_amount(psbt_str: String) -> Option<u64> {
        let psbt = PartiallySignedTransaction::new(psbt_str);
        psbt.unwrap().fee_amount()
    }
    pub fn combine_psbt(psbt_str: String, other: String) -> anyhow::Result<String, Error> {
        let psbt = PartiallySignedTransaction::new(psbt_str).unwrap();
        let other = PartiallySignedTransaction::new(other).unwrap();
        return match psbt.combine(Arc::new(other)) {
            Ok(e) => Ok(e.serialize()),
            Err(e) => Err(e.into()),
        };
    }
    pub fn json_serialize(psbt_str: String) -> anyhow::Result<String, Error> {
        let psbt = PartiallySignedTransaction::new(psbt_str).unwrap();
        Ok(psbt.json_serialize())
    }

    //========TxBuilder==========
    pub fn tx_builder_finish(
        wallet_id: String,
        recipients: Vec<ScriptAmount>,
        utxos: Vec<OutPoint>,
        foreign_utxo: Option<(OutPoint, String, usize)>,
        unspendable: Vec<OutPoint>,
        change_policy: ChangeSpendPolicy,
        manually_selected_only: bool,
        fee_rate: Option<f32>,
        fee_absolute: Option<u64>,
        drain_wallet: bool,
        drain_to: Option<Script>,
        rbf: Option<RbfValue>,
        data: Vec<u8>,
    ) -> anyhow::Result<(String, TransactionDetails), Error> {
        let binding = Wallet::retrieve_wallet(wallet_id);
        let binding = binding.get_wallet();

        let mut tx_builder = binding.build_tx();

        for e in recipients {
            tx_builder.add_recipient(e.script.into(), e.amount);
        }
        tx_builder.change_policy(change_policy.into());

        if !utxos.is_empty() {
            let bdk_utxos: Vec<BdkOutPoint> = utxos.iter().map(BdkOutPoint::from).collect();
            let utxos: &[BdkOutPoint] = &bdk_utxos;
            tx_builder.add_utxos(utxos).unwrap();
        }
        if !unspendable.is_empty() {
            let bdk_unspendable: Vec<BdkOutPoint> =
                unspendable.iter().map(BdkOutPoint::from).collect();
            tx_builder.unspendable(bdk_unspendable);
        }
        if manually_selected_only {
            tx_builder.manually_selected_only();
        }
        if let Some(sat_per_vb) = fee_rate {
            tx_builder.fee_rate(bdk::FeeRate::from_sat_per_vb(sat_per_vb));
        }
        if let Some(fee_amount) = fee_absolute {
            tx_builder.fee_absolute(fee_amount);
        }
        if drain_wallet {
            tx_builder.drain_wallet();
        }
        if let Some(script_) = drain_to {
            tx_builder.drain_to(script_.into());
        }
        if let Some(f_utxo) = foreign_utxo {
            let input = to_input(f_utxo.1);
            tx_builder
                .add_foreign_utxo(f_utxo.0.borrow().into(), input, f_utxo.2)
                .expect("Error adding foreign_utxo!");
        }
        if let Some(rbf) = &rbf {
            match rbf {
                RbfValue::RbfDefault => {
                    tx_builder.enable_rbf();
                }
                RbfValue::Value(nsequence) => {
                    tx_builder.enable_rbf_with_sequence(Sequence(nsequence.to_owned()));
                }
            }
        }
        if !data.is_empty() {
            tx_builder.add_data(data.as_slice());
        }

        return match tx_builder.finish() {
            Ok(e) => Ok((
                PartiallySignedTransaction {
                    internal: Mutex::new(e.0),
                }
                .serialize(),
                TransactionDetails::from(&e.1),
            )),
            Err(e) => Err(e.into()),
        };
    }

    //========BumpFeeTxBuilder==========
    pub fn bump_fee_tx_builder_finish(
        txid: String,
        fee_rate: f32,
        allow_shrinking: Option<String>,
        wallet_id: String,
        enable_rbf: bool,
        n_sequence: Option<u32>,
    ) -> anyhow::Result<(String, TransactionDetails), Error> {
        let txid = Txid::from_str(txid.as_str()).unwrap();
        let binding = Wallet::retrieve_wallet(wallet_id);
        let bdk_wallet = binding.get_wallet();

        let mut tx_builder = bdk_wallet.build_fee_bump(txid)?;
        tx_builder.fee_rate(bdk::FeeRate::from_sat_per_vb(fee_rate));
        if let Some(allow_shrinking) = &allow_shrinking {
            let address = BdkAddress::from_str(allow_shrinking)
                .map_err(|e| Error::Generic(e.to_string()))
                .unwrap();
            let script = address.script_pubkey();
            tx_builder.allow_shrinking(script).unwrap();
        }
        if let Some(n_sequence) = n_sequence {
            tx_builder.enable_rbf_with_sequence(Sequence(n_sequence));
        }
        if enable_rbf {
            tx_builder.enable_rbf();
        }
        return match tx_builder.finish() {
            Ok(e) => Ok((
                PartiallySignedTransaction {
                    internal: Mutex::new(e.0),
                }
                .serialize(),
                TransactionDetails::from(&e.1),
            )),
            Err(e) => Err(e.into()),
        };
    }

    //================Descriptor=========
    //Checking if the descriptor has any errors
    pub fn create_descriptor(
        descriptor: String,
        network: Network,
    ) -> anyhow::Result<String, Error> {
        return match BdkDescriptor::new(descriptor, network.into()) {
            Ok(e) => Ok(e.as_string_private()),
            Err(e) => Err(e.into()),
        };
    }
    pub fn new_bip44_descriptor(
        key_chain_kind: KeychainKind,
        secret_key: String,
        network: Network,
    ) -> anyhow::Result<String, Error> {
        let key = DescriptorSecretKey::from_string(secret_key)?;
        let descriptor = BdkDescriptor::new_bip44(key, key_chain_kind.into(), network.into());
        Ok(descriptor.as_string_private())
    }
    pub fn new_bip44_public(
        key_chain_kind: KeychainKind,
        public_key: String,
        network: Network,
        fingerprint: String,
    ) -> anyhow::Result<String, Error> {
        let key = DescriptorPublicKey::from_string(public_key)?;
        let descriptor = BdkDescriptor::new_bip44_public(
            key,
            fingerprint,
            key_chain_kind.into(),
            network.into(),
        );
        Ok(descriptor.as_string())
    }
    pub fn new_bip49_descriptor(
        key_chain_kind: KeychainKind,
        secret_key: String,
        network: Network,
    ) -> anyhow::Result<String, Error> {
        let key = DescriptorSecretKey::from_string(secret_key)?;
        let descriptor = BdkDescriptor::new_bip49(key, key_chain_kind.into(), network.into());
        Ok(descriptor.as_string_private())
    }
    pub fn new_bip49_public(
        key_chain_kind: KeychainKind,
        public_key: String,
        network: Network,
        fingerprint: String,
    ) -> anyhow::Result<String, Error> {
        let key = DescriptorPublicKey::from_string(public_key)?;
        let descriptor = BdkDescriptor::new_bip49_public(
            key,
            fingerprint,
            key_chain_kind.into(),
            network.into(),
        );
        Ok(descriptor.as_string())
    }
    pub fn new_bip84_descriptor(
        key_chain_kind: KeychainKind,
        secret_key: String,
        network: Network,
    ) -> anyhow::Result<String, Error> {
        let key = DescriptorSecretKey::from_string(secret_key)?;
        let descriptor = BdkDescriptor::new_bip84(key, key_chain_kind.into(), network.into());
        Ok(descriptor.as_string_private())
    }
    pub fn new_bip84_public(
        key_chain_kind: KeychainKind,
        public_key: String,
        network: Network,
        fingerprint: String,
    ) -> anyhow::Result<String, Error> {
        let key: DescriptorPublicKey = DescriptorPublicKey::from_string(public_key)?;
        let descriptor = BdkDescriptor::new_bip84_public(
            key,
            fingerprint,
            key_chain_kind.into(),
            network.into(),
        );
        Ok(descriptor.as_string())
    }
    pub fn descriptor_as_string_private(
        descriptor: String,
        network: Network,
    ) -> anyhow::Result<String, Error> {
        let descriptor = BdkDescriptor::new(descriptor, network.into());
        Ok(descriptor?.as_string_private())
    }
    pub fn descriptor_as_string(
        descriptor: String,
        network: Network,
    ) -> anyhow::Result<String, Error> {
        let descriptor = BdkDescriptor::new(descriptor, network.into());
        Ok(descriptor?.as_string())
    }
    pub fn max_satisfaction_weight(
        descriptor: String,
        network: Network,
    ) -> anyhow::Result<usize, Error> {
        Ok(BdkDescriptor::new(descriptor, network.into())?.max_satisfaction_weight()?)
    }
    //====================== Descriptor Secret =================
    pub fn create_descriptor_secret(
        network: Network,
        mnemonic: String,
        password: Option<String>,
    ) -> anyhow::Result<String, Error> {
        let mnemonic = Mnemonic::from_str(mnemonic)?;
        Ok(DescriptorSecretKey::new(network.into(), mnemonic, password)?.as_string())
    }
    pub fn descriptor_secret_from_string(secret: String) -> anyhow::Result<String> {
        Ok(DescriptorSecretKey::from_string(secret)?.as_string())
    }
    pub fn extend_descriptor_secret(secret: String, path: String) -> String {
        let res = Self::descriptor_secret_config(secret, Some(path), false);
        res.as_string()
    }
    pub fn derive_descriptor_secret(secret: String, path: String) -> String {
        let res = Self::descriptor_secret_config(secret, Some(path), true);
        res.as_string()
    }
    pub fn descriptor_secret_as_secret_bytes(secret: String) -> anyhow::Result<Vec<u8>, Error> {
        let secret = BdkDescriptorSecretKey::from_str(secret.as_str())?;
        let descriptor_secret = DescriptorSecretKey {
            descriptor_secret_key_mutex: Mutex::new(secret),
        };
        Ok(descriptor_secret.secret_bytes()?)
    }
    pub fn descriptor_secret_as_public(secret: String) -> anyhow::Result<String, Error> {
        let secret = BdkDescriptorSecretKey::from_str(secret.as_str())?;
        let descriptor_secret = DescriptorSecretKey {
            descriptor_secret_key_mutex: Mutex::new(secret),
        };
        Ok(descriptor_secret.as_public()?.as_string())
    }
    fn descriptor_secret_config(
        secret: String,
        path: Option<String>,
        derive: bool,
    ) -> Arc<DescriptorSecretKey> {
        let secret = match BdkDescriptorSecretKey::from_str(secret.as_str()) {
            Ok(e) => e,
            Err(e) => panic!("{:?}", e),
        };
        let descriptor_secret = DescriptorSecretKey {
            descriptor_secret_key_mutex: Mutex::new(secret),
        };

        if path.is_none() {
            return Arc::new(descriptor_secret);
        }
        let derivation_path =
            Arc::new(DerivationPath::new(path.unwrap().to_string()).expect("Invalid path"));
        return if derive {
            match descriptor_secret.derive(derivation_path) {
                Ok(e) => e,
                Err(e) => panic!("{:?}", e),
            }
        } else {
            match descriptor_secret.extend(derivation_path) {
                Ok(e) => e,
                Err(e) => panic!("{:?}", e),
            }
        };
    }

    //==============Derivation Path ==========
    pub fn create_derivation_path(path: String) -> anyhow::Result<String, Error> {
        Ok(DerivationPath::new(path)?.as_string())
    }

    //================Descriptor Public=========
    pub fn descriptor_public_from_string(public_key: String) -> anyhow::Result<String, Error> {
        Ok(DescriptorPublicKey::from_string(public_key)?.as_string())
    }
    pub fn create_descriptor_public(
        xpub: Option<String>,
        path: String,
        derive: bool,
    ) -> anyhow::Result<String, Error> {
        let derivation_path = Arc::new(DerivationPath::new(path.to_string()).unwrap());
        let descriptor_public = DescriptorPublicKey::from_string(xpub.unwrap()).unwrap();
        return if derive {
            Ok(descriptor_public.derive(derivation_path)?.as_string())
        } else {
            Ok(descriptor_public.extend(derivation_path)?.as_string())
        };
    }

    //============ Script Class===========
    pub fn create_script(raw_output_script: Vec<u8>) -> anyhow::Result<Script, Error> {
        Ok(Script::new(raw_output_script)?)
    }

    //================Address============
    pub fn create_address(address: String) -> anyhow::Result<String, Error> {
        Ok(Address::new(address)?.address.to_string())
    }
    pub fn address_from_script(script: Script, network: Network) -> anyhow::Result<String, Error> {
        Ok(Address::from_script(script, network.into())?
            .address
            .to_string())
    }
    pub fn address_to_script_pubkey(address: String) -> anyhow::Result<Script, Error> {
        Ok(Address::new(address)?.script_pubkey())
    }
    pub fn payload(address: String) -> anyhow::Result<Payload, Error> {
        Ok(Address::new(address)?.payload())
    }
    pub fn address_network(address: String) -> anyhow::Result<Network, Error> {
        Ok(Address::new(address)?.network())
    }

    //========Wallet==========
    pub fn create_wallet(
        descriptor: String,
        change_descriptor: Option<String>,
        network: Network,
        database_config: DatabaseConfig,
    ) -> anyhow::Result<String, Error> {
        Ok(Wallet::new(
            descriptor,
            change_descriptor,
            network.into(),
            database_config,
        )?)
    }

    pub fn get_address(
        wallet_id: String,
        address_index: AddressIndex,
    ) -> anyhow::Result<AddressInfo, Error> {
        Ok(Wallet::retrieve_wallet(wallet_id).get_address(address_index)?)
    }
    pub fn is_mine(script: Script, wallet_id: String) -> anyhow::Result<bool, Error> {
        Ok(Wallet::retrieve_wallet(wallet_id).is_mine(script.into())?)
    }
    pub fn get_internal_address(
        wallet_id: String,
        address_index: AddressIndex,
    ) -> anyhow::Result<AddressInfo, Error> {
        Ok(Wallet::retrieve_wallet(wallet_id).get_internal_address(address_index)?)
    }
    pub fn sync_wallet(wallet_id: String, blockchain_id: String) {
        Wallet::retrieve_wallet(wallet_id)
            .sync(Blockchain::retrieve_blockchain(blockchain_id).deref(), None);
    }
    pub fn get_balance(wallet_id: String) -> anyhow::Result<Balance, Error> {
        Ok(Wallet::retrieve_wallet(wallet_id).get_balance()?)
    }
    pub fn list_unspent_outputs(wallet_id: String) -> anyhow::Result<Vec<LocalUtxo>, Error> {
        Ok(Wallet::retrieve_wallet(wallet_id).list_unspent()?)
    }
    pub fn get_transactions(
        wallet_id: String,
        include_raw: bool,
    ) -> anyhow::Result<Vec<TransactionDetails>, Error> {
        Ok(Wallet::retrieve_wallet(wallet_id).list_transactions(include_raw)?)
    }
    pub fn sign(
        wallet_id: String,
        psbt_str: String,
        sign_options: Option<SignOptions>,
    ) -> anyhow::Result<Option<String>, Error> {
        let psbt = PartiallySignedTransaction::new(psbt_str)?;
        let signed = Wallet::retrieve_wallet(wallet_id).sign(&psbt, sign_options.clone())?;
        match signed {
            true => Ok(Some(psbt.serialize())),
            false => {
                if let Some(sign_option) = sign_options {
                    if sign_option.is_multi_sig {
                        Ok(Some(psbt.serialize()))
                    } else {
                        Ok(None)
                    }
                } else {
                    Ok(None)
                }
            }
        }
    }
    pub fn wallet_network(wallet_id: String) -> Network {
        Wallet::retrieve_wallet(wallet_id)
            .get_wallet()
            .network()
            .into()
    }
    pub fn list_unspent(wallet_id: String) -> anyhow::Result<Vec<LocalUtxo>, Error> {
        Ok(Wallet::retrieve_wallet(wallet_id).list_unspent()?)
    }
    /// get the corresponding PSBT Input for a LocalUtxo
    pub fn get_psbt_input(
        wallet_id: String,
        utxo: LocalUtxo,
        only_witness_utxo: bool,
        psbt_sighash_type: Option<PsbtSigHashType>,
    ) -> anyhow::Result<String, Error> {
        let input = Wallet::retrieve_wallet(wallet_id).get_psbt_input(
            utxo,
            only_witness_utxo,
            psbt_sighash_type,
        )?;
        Ok(serde_json::to_string(&input)?)
    }

    pub fn get_descriptor_for_keychain(
        wallet_id: String,
        keychain: KeychainKind,
    ) -> anyhow::Result<(String, Network), Error> {
        let wallet = Wallet::retrieve_wallet(wallet_id);
        let network: Network = wallet.get_wallet().network().into();
        match wallet.get_descriptor_for_keychain(keychain.into()) {
            Ok(e) => Ok((e.as_string_private(), network)),
            Err(e) => Err(e.into()),
        }
    }
    //================== Mnemonic ==========
    pub fn generate_seed_from_word_count(word_count: WordCount) -> String {
        let mnemonic = Mnemonic::new(word_count.into());
        mnemonic.as_string()
    }
    pub fn generate_seed_from_string(mnemonic: String) -> anyhow::Result<String, Error> {
        Ok(Mnemonic::from_str(mnemonic)?.as_string())
    }
    pub fn generate_seed_from_entropy(entropy: Vec<u8>) -> anyhow::Result<String, Error> {
        Ok(Mnemonic::from_entropy(entropy)?.as_string())
    }
}

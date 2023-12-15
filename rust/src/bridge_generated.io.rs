use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_create_esplora_blockchain__static_method__Api(
    port_: i64,
    config: *mut wire_EsploraConfig,
) {
    wire_create_esplora_blockchain__static_method__Api_impl(port_, config)
}

#[no_mangle]
pub extern "C" fn wire_create_electrum_blockchain__static_method__Api(
    port_: i64,
    config: *mut wire_ElectrumConfig,
) {
    wire_create_electrum_blockchain__static_method__Api_impl(port_, config)
}

#[no_mangle]
pub extern "C" fn wire_get_height__static_method__Api(
    port_: i64,
    blockchain_id: *mut wire_uint_8_list,
) {
    wire_get_height__static_method__Api_impl(port_, blockchain_id)
}

#[no_mangle]
pub extern "C" fn wire_get_blockchain_hash__static_method__Api(
    port_: i64,
    blockchain_height: u32,
    blockchain_id: *mut wire_uint_8_list,
) {
    wire_get_blockchain_hash__static_method__Api_impl(port_, blockchain_height, blockchain_id)
}

#[no_mangle]
pub extern "C" fn wire_estimate_fee__static_method__Api(
    port_: i64,
    target: u64,
    blockchain_id: *mut wire_uint_8_list,
) {
    wire_estimate_fee__static_method__Api_impl(port_, target, blockchain_id)
}

#[no_mangle]
pub extern "C" fn wire_broadcast__static_method__Api(
    port_: i64,
    tx: *mut wire_uint_8_list,
    blockchain_id: *mut wire_uint_8_list,
) {
    wire_broadcast__static_method__Api_impl(port_, tx, blockchain_id)
}

#[no_mangle]
pub extern "C" fn wire_create_transaction__static_method__Api(
    port_: i64,
    tx: *mut wire_uint_8_list,
) {
    wire_create_transaction__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_tx_txid__static_method__Api(port_: i64, tx: *mut wire_uint_8_list) {
    wire_tx_txid__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_weight__static_method__Api(port_: i64, tx: *mut wire_uint_8_list) {
    wire_weight__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_size__static_method__Api(port_: i64, tx: *mut wire_uint_8_list) {
    wire_size__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_vsize__static_method__Api(port_: i64, tx: *mut wire_uint_8_list) {
    wire_vsize__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_serialize_tx__static_method__Api(port_: i64, tx: *mut wire_uint_8_list) {
    wire_serialize_tx__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_is_coin_base__static_method__Api(port_: i64, tx: *mut wire_uint_8_list) {
    wire_is_coin_base__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_is_explicitly_rbf__static_method__Api(
    port_: i64,
    tx: *mut wire_uint_8_list,
) {
    wire_is_explicitly_rbf__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_is_lock_time_enabled__static_method__Api(
    port_: i64,
    tx: *mut wire_uint_8_list,
) {
    wire_is_lock_time_enabled__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_version__static_method__Api(port_: i64, tx: *mut wire_uint_8_list) {
    wire_version__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_lock_time__static_method__Api(port_: i64, tx: *mut wire_uint_8_list) {
    wire_lock_time__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_input__static_method__Api(port_: i64, tx: *mut wire_uint_8_list) {
    wire_input__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_output__static_method__Api(port_: i64, tx: *mut wire_uint_8_list) {
    wire_output__static_method__Api_impl(port_, tx)
}

#[no_mangle]
pub extern "C" fn wire_serialize_psbt__static_method__Api(
    port_: i64,
    psbt_str: *mut wire_uint_8_list,
) {
    wire_serialize_psbt__static_method__Api_impl(port_, psbt_str)
}

#[no_mangle]
pub extern "C" fn wire_psbt_txid__static_method__Api(port_: i64, psbt_str: *mut wire_uint_8_list) {
    wire_psbt_txid__static_method__Api_impl(port_, psbt_str)
}

#[no_mangle]
pub extern "C" fn wire_extract_tx__static_method__Api(port_: i64, psbt_str: *mut wire_uint_8_list) {
    wire_extract_tx__static_method__Api_impl(port_, psbt_str)
}

#[no_mangle]
pub extern "C" fn wire_psbt_fee_rate__static_method__Api(
    port_: i64,
    psbt_str: *mut wire_uint_8_list,
) {
    wire_psbt_fee_rate__static_method__Api_impl(port_, psbt_str)
}

#[no_mangle]
pub extern "C" fn wire_psbt_fee_amount__static_method__Api(
    port_: i64,
    psbt_str: *mut wire_uint_8_list,
) {
    wire_psbt_fee_amount__static_method__Api_impl(port_, psbt_str)
}

#[no_mangle]
pub extern "C" fn wire_combine_psbt__static_method__Api(
    port_: i64,
    psbt_str: *mut wire_uint_8_list,
    other: *mut wire_uint_8_list,
) {
    wire_combine_psbt__static_method__Api_impl(port_, psbt_str, other)
}

#[no_mangle]
pub extern "C" fn wire_json_serialize__static_method__Api(
    port_: i64,
    psbt_str: *mut wire_uint_8_list,
) {
    wire_json_serialize__static_method__Api_impl(port_, psbt_str)
}

#[no_mangle]
pub extern "C" fn wire_tx_builder_finish__static_method__Api(
    port_: i64,
    wallet_id: *mut wire_uint_8_list,
    recipients: *mut wire_list_script_amount,
    utxos: *mut wire_list_out_point,
    foreign_utxo: *mut wire___record__out_point_String_usize,
    unspendable: *mut wire_list_out_point,
    change_policy: i32,
    manually_selected_only: bool,
    fee_rate: *mut f32,
    fee_absolute: *mut u64,
    drain_wallet: bool,
    drain_to: *mut wire_Script,
    rbf: *mut wire_RbfValue,
    data: *mut wire_uint_8_list,
) {
    wire_tx_builder_finish__static_method__Api_impl(
        port_,
        wallet_id,
        recipients,
        utxos,
        foreign_utxo,
        unspendable,
        change_policy,
        manually_selected_only,
        fee_rate,
        fee_absolute,
        drain_wallet,
        drain_to,
        rbf,
        data,
    )
}

#[no_mangle]
pub extern "C" fn wire_bump_fee_tx_builder_finish__static_method__Api(
    port_: i64,
    txid: *mut wire_uint_8_list,
    fee_rate: f32,
    allow_shrinking: *mut wire_uint_8_list,
    wallet_id: *mut wire_uint_8_list,
    enable_rbf: bool,
    n_sequence: *mut u32,
) {
    wire_bump_fee_tx_builder_finish__static_method__Api_impl(
        port_,
        txid,
        fee_rate,
        allow_shrinking,
        wallet_id,
        enable_rbf,
        n_sequence,
    )
}

#[no_mangle]
pub extern "C" fn wire_create_descriptor__static_method__Api(
    port_: i64,
    descriptor: *mut wire_uint_8_list,
    network: i32,
) {
    wire_create_descriptor__static_method__Api_impl(port_, descriptor, network)
}

#[no_mangle]
pub extern "C" fn wire_new_bip44_descriptor__static_method__Api(
    port_: i64,
    key_chain_kind: i32,
    secret_key: *mut wire_uint_8_list,
    network: i32,
) {
    wire_new_bip44_descriptor__static_method__Api_impl(port_, key_chain_kind, secret_key, network)
}

#[no_mangle]
pub extern "C" fn wire_new_bip44_public__static_method__Api(
    port_: i64,
    key_chain_kind: i32,
    public_key: *mut wire_uint_8_list,
    network: i32,
    fingerprint: *mut wire_uint_8_list,
) {
    wire_new_bip44_public__static_method__Api_impl(
        port_,
        key_chain_kind,
        public_key,
        network,
        fingerprint,
    )
}

#[no_mangle]
pub extern "C" fn wire_new_bip49_descriptor__static_method__Api(
    port_: i64,
    key_chain_kind: i32,
    secret_key: *mut wire_uint_8_list,
    network: i32,
) {
    wire_new_bip49_descriptor__static_method__Api_impl(port_, key_chain_kind, secret_key, network)
}

#[no_mangle]
pub extern "C" fn wire_new_bip49_public__static_method__Api(
    port_: i64,
    key_chain_kind: i32,
    public_key: *mut wire_uint_8_list,
    network: i32,
    fingerprint: *mut wire_uint_8_list,
) {
    wire_new_bip49_public__static_method__Api_impl(
        port_,
        key_chain_kind,
        public_key,
        network,
        fingerprint,
    )
}

#[no_mangle]
pub extern "C" fn wire_new_bip84_descriptor__static_method__Api(
    port_: i64,
    key_chain_kind: i32,
    secret_key: *mut wire_uint_8_list,
    network: i32,
) {
    wire_new_bip84_descriptor__static_method__Api_impl(port_, key_chain_kind, secret_key, network)
}

#[no_mangle]
pub extern "C" fn wire_new_bip84_public__static_method__Api(
    port_: i64,
    key_chain_kind: i32,
    public_key: *mut wire_uint_8_list,
    network: i32,
    fingerprint: *mut wire_uint_8_list,
) {
    wire_new_bip84_public__static_method__Api_impl(
        port_,
        key_chain_kind,
        public_key,
        network,
        fingerprint,
    )
}

#[no_mangle]
pub extern "C" fn wire_descriptor_as_string_private__static_method__Api(
    port_: i64,
    descriptor: *mut wire_uint_8_list,
    network: i32,
) {
    wire_descriptor_as_string_private__static_method__Api_impl(port_, descriptor, network)
}

#[no_mangle]
pub extern "C" fn wire_descriptor_as_string__static_method__Api(
    port_: i64,
    descriptor: *mut wire_uint_8_list,
    network: i32,
) {
    wire_descriptor_as_string__static_method__Api_impl(port_, descriptor, network)
}

#[no_mangle]
pub extern "C" fn wire_max_satisfaction_weight__static_method__Api(
    port_: i64,
    descriptor: *mut wire_uint_8_list,
    network: i32,
) {
    wire_max_satisfaction_weight__static_method__Api_impl(port_, descriptor, network)
}

#[no_mangle]
pub extern "C" fn wire_create_descriptor_secret__static_method__Api(
    port_: i64,
    network: i32,
    mnemonic: *mut wire_uint_8_list,
    password: *mut wire_uint_8_list,
) {
    wire_create_descriptor_secret__static_method__Api_impl(port_, network, mnemonic, password)
}

#[no_mangle]
pub extern "C" fn wire_descriptor_secret_from_string__static_method__Api(
    port_: i64,
    secret: *mut wire_uint_8_list,
) {
    wire_descriptor_secret_from_string__static_method__Api_impl(port_, secret)
}

#[no_mangle]
pub extern "C" fn wire_extend_descriptor_secret__static_method__Api(
    port_: i64,
    secret: *mut wire_uint_8_list,
    path: *mut wire_uint_8_list,
) {
    wire_extend_descriptor_secret__static_method__Api_impl(port_, secret, path)
}

#[no_mangle]
pub extern "C" fn wire_derive_descriptor_secret__static_method__Api(
    port_: i64,
    secret: *mut wire_uint_8_list,
    path: *mut wire_uint_8_list,
) {
    wire_derive_descriptor_secret__static_method__Api_impl(port_, secret, path)
}

#[no_mangle]
pub extern "C" fn wire_descriptor_secret_as_secret_bytes__static_method__Api(
    port_: i64,
    secret: *mut wire_uint_8_list,
) {
    wire_descriptor_secret_as_secret_bytes__static_method__Api_impl(port_, secret)
}

#[no_mangle]
pub extern "C" fn wire_descriptor_secret_as_public__static_method__Api(
    port_: i64,
    secret: *mut wire_uint_8_list,
) {
    wire_descriptor_secret_as_public__static_method__Api_impl(port_, secret)
}

#[no_mangle]
pub extern "C" fn wire_create_derivation_path__static_method__Api(
    port_: i64,
    path: *mut wire_uint_8_list,
) {
    wire_create_derivation_path__static_method__Api_impl(port_, path)
}

#[no_mangle]
pub extern "C" fn wire_descriptor_public_from_string__static_method__Api(
    port_: i64,
    public_key: *mut wire_uint_8_list,
) {
    wire_descriptor_public_from_string__static_method__Api_impl(port_, public_key)
}

#[no_mangle]
pub extern "C" fn wire_create_descriptor_public__static_method__Api(
    port_: i64,
    xpub: *mut wire_uint_8_list,
    path: *mut wire_uint_8_list,
    derive: bool,
) {
    wire_create_descriptor_public__static_method__Api_impl(port_, xpub, path, derive)
}

#[no_mangle]
pub extern "C" fn wire_create_script__static_method__Api(
    port_: i64,
    raw_output_script: *mut wire_uint_8_list,
) {
    wire_create_script__static_method__Api_impl(port_, raw_output_script)
}

#[no_mangle]
pub extern "C" fn wire_create_address__static_method__Api(
    port_: i64,
    address: *mut wire_uint_8_list,
) {
    wire_create_address__static_method__Api_impl(port_, address)
}

#[no_mangle]
pub extern "C" fn wire_address_from_script__static_method__Api(
    port_: i64,
    script: *mut wire_Script,
    network: i32,
) {
    wire_address_from_script__static_method__Api_impl(port_, script, network)
}

#[no_mangle]
pub extern "C" fn wire_address_to_script_pubkey__static_method__Api(
    port_: i64,
    address: *mut wire_uint_8_list,
) {
    wire_address_to_script_pubkey__static_method__Api_impl(port_, address)
}

#[no_mangle]
pub extern "C" fn wire_payload__static_method__Api(port_: i64, address: *mut wire_uint_8_list) {
    wire_payload__static_method__Api_impl(port_, address)
}

#[no_mangle]
pub extern "C" fn wire_address_network__static_method__Api(
    port_: i64,
    address: *mut wire_uint_8_list,
) {
    wire_address_network__static_method__Api_impl(port_, address)
}

#[no_mangle]
pub extern "C" fn wire_create_wallet__static_method__Api(
    port_: i64,
    descriptor: *mut wire_uint_8_list,
    change_descriptor: *mut wire_uint_8_list,
    network: i32,
    database_config: *mut wire_DatabaseConfig,
) {
    wire_create_wallet__static_method__Api_impl(
        port_,
        descriptor,
        change_descriptor,
        network,
        database_config,
    )
}

#[no_mangle]
pub extern "C" fn wire_get_address__static_method__Api(
    port_: i64,
    wallet_id: *mut wire_uint_8_list,
    address_index: *mut wire_AddressIndex,
) {
    wire_get_address__static_method__Api_impl(port_, wallet_id, address_index)
}

#[no_mangle]
pub extern "C" fn wire_is_mine__static_method__Api(
    port_: i64,
    script: *mut wire_Script,
    wallet_id: *mut wire_uint_8_list,
) {
    wire_is_mine__static_method__Api_impl(port_, script, wallet_id)
}

#[no_mangle]
pub extern "C" fn wire_get_internal_address__static_method__Api(
    port_: i64,
    wallet_id: *mut wire_uint_8_list,
    address_index: *mut wire_AddressIndex,
) {
    wire_get_internal_address__static_method__Api_impl(port_, wallet_id, address_index)
}

#[no_mangle]
pub extern "C" fn wire_sync_wallet__static_method__Api(
    port_: i64,
    wallet_id: *mut wire_uint_8_list,
    blockchain_id: *mut wire_uint_8_list,
) {
    wire_sync_wallet__static_method__Api_impl(port_, wallet_id, blockchain_id)
}

#[no_mangle]
pub extern "C" fn wire_get_balance__static_method__Api(
    port_: i64,
    wallet_id: *mut wire_uint_8_list,
) {
    wire_get_balance__static_method__Api_impl(port_, wallet_id)
}

#[no_mangle]
pub extern "C" fn wire_list_unspent_outputs__static_method__Api(
    port_: i64,
    wallet_id: *mut wire_uint_8_list,
) {
    wire_list_unspent_outputs__static_method__Api_impl(port_, wallet_id)
}

#[no_mangle]
pub extern "C" fn wire_get_transactions__static_method__Api(
    port_: i64,
    wallet_id: *mut wire_uint_8_list,
    include_raw: bool,
) {
    wire_get_transactions__static_method__Api_impl(port_, wallet_id, include_raw)
}

#[no_mangle]
pub extern "C" fn wire_sign__static_method__Api(
    port_: i64,
    wallet_id: *mut wire_uint_8_list,
    psbt_str: *mut wire_uint_8_list,
    sign_options: *mut wire_SignOptions,
) {
    wire_sign__static_method__Api_impl(port_, wallet_id, psbt_str, sign_options)
}

#[no_mangle]
pub extern "C" fn wire_wallet_network__static_method__Api(
    port_: i64,
    wallet_id: *mut wire_uint_8_list,
) {
    wire_wallet_network__static_method__Api_impl(port_, wallet_id)
}

#[no_mangle]
pub extern "C" fn wire_list_unspent__static_method__Api(
    port_: i64,
    wallet_id: *mut wire_uint_8_list,
) {
    wire_list_unspent__static_method__Api_impl(port_, wallet_id)
}

#[no_mangle]
pub extern "C" fn wire_get_psbt_input__static_method__Api(
    port_: i64,
    wallet_id: *mut wire_uint_8_list,
    utxo: *mut wire_LocalUtxo,
    only_witness_utxo: bool,
    psbt_sighash_type: *mut wire_PsbtSigHashType,
) {
    wire_get_psbt_input__static_method__Api_impl(
        port_,
        wallet_id,
        utxo,
        only_witness_utxo,
        psbt_sighash_type,
    )
}

#[no_mangle]
pub extern "C" fn wire_get_descriptor_for_keychain__static_method__Api(
    port_: i64,
    wallet_id: *mut wire_uint_8_list,
    keychain: i32,
) {
    wire_get_descriptor_for_keychain__static_method__Api_impl(port_, wallet_id, keychain)
}

#[no_mangle]
pub extern "C" fn wire_generate_seed_from_word_count__static_method__Api(
    port_: i64,
    word_count: i32,
) {
    wire_generate_seed_from_word_count__static_method__Api_impl(port_, word_count)
}

#[no_mangle]
pub extern "C" fn wire_generate_seed_from_string__static_method__Api(
    port_: i64,
    mnemonic: *mut wire_uint_8_list,
) {
    wire_generate_seed_from_string__static_method__Api_impl(port_, mnemonic)
}

#[no_mangle]
pub extern "C" fn wire_generate_seed_from_entropy__static_method__Api(
    port_: i64,
    entropy: *mut wire_uint_8_list,
) {
    wire_generate_seed_from_entropy__static_method__Api_impl(port_, entropy)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_box_autoadd___record__out_point_String_usize_0(
) -> *mut wire___record__out_point_String_usize {
    support::new_leak_box_ptr(wire___record__out_point_String_usize::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_address_index_0() -> *mut wire_AddressIndex {
    support::new_leak_box_ptr(wire_AddressIndex::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_database_config_0() -> *mut wire_DatabaseConfig {
    support::new_leak_box_ptr(wire_DatabaseConfig::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_electrum_config_0() -> *mut wire_ElectrumConfig {
    support::new_leak_box_ptr(wire_ElectrumConfig::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_esplora_config_0() -> *mut wire_EsploraConfig {
    support::new_leak_box_ptr(wire_EsploraConfig::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_f32_0(value: f32) -> *mut f32 {
    support::new_leak_box_ptr(value)
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_local_utxo_0() -> *mut wire_LocalUtxo {
    support::new_leak_box_ptr(wire_LocalUtxo::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_psbt_sig_hash_type_0() -> *mut wire_PsbtSigHashType {
    support::new_leak_box_ptr(wire_PsbtSigHashType::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_rbf_value_0() -> *mut wire_RbfValue {
    support::new_leak_box_ptr(wire_RbfValue::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_script_0() -> *mut wire_Script {
    support::new_leak_box_ptr(wire_Script::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_sign_options_0() -> *mut wire_SignOptions {
    support::new_leak_box_ptr(wire_SignOptions::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_sled_db_configuration_0() -> *mut wire_SledDbConfiguration {
    support::new_leak_box_ptr(wire_SledDbConfiguration::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_sqlite_db_configuration_0() -> *mut wire_SqliteDbConfiguration {
    support::new_leak_box_ptr(wire_SqliteDbConfiguration::new_with_null_ptr())
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_u32_0(value: u32) -> *mut u32 {
    support::new_leak_box_ptr(value)
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_u64_0(value: u64) -> *mut u64 {
    support::new_leak_box_ptr(value)
}

#[no_mangle]
pub extern "C" fn new_box_autoadd_u8_0(value: u8) -> *mut u8 {
    support::new_leak_box_ptr(value)
}

#[no_mangle]
pub extern "C" fn new_list_out_point_0(len: i32) -> *mut wire_list_out_point {
    let wrap =
        wire_list_out_point {
            ptr: support::new_leak_vec_ptr(<wire_OutPoint>::new_with_null_ptr(), len),
            len,
        };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_list_script_amount_0(len: i32) -> *mut wire_list_script_amount {
    let wrap = wire_list_script_amount {
        ptr: support::new_leak_vec_ptr(<wire_ScriptAmount>::new_with_null_ptr(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}
impl Wire2Api<(OutPoint, String, usize)> for wire___record__out_point_String_usize {
    fn wire2api(self) -> (OutPoint, String, usize) {
        (
            self.field0.wire2api(),
            self.field1.wire2api(),
            self.field2.wire2api(),
        )
    }
}
impl Wire2Api<AddressIndex> for wire_AddressIndex {
    fn wire2api(self) -> AddressIndex {
        match self.tag {
            0 => AddressIndex::New,
            1 => AddressIndex::LastUnused,
            2 => unsafe {
                let ans = support::box_from_leak_ptr(self.kind);
                let ans = support::box_from_leak_ptr(ans.Peek);
                AddressIndex::Peek {
                    index: ans.index.wire2api(),
                }
            },
            3 => unsafe {
                let ans = support::box_from_leak_ptr(self.kind);
                let ans = support::box_from_leak_ptr(ans.Reset);
                AddressIndex::Reset {
                    index: ans.index.wire2api(),
                }
            },
            _ => unreachable!(),
        }
    }
}

impl Wire2Api<(OutPoint, String, usize)> for *mut wire___record__out_point_String_usize {
    fn wire2api(self) -> (OutPoint, String, usize) {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<(OutPoint, String, usize)>::wire2api(*wrap).into()
    }
}
impl Wire2Api<AddressIndex> for *mut wire_AddressIndex {
    fn wire2api(self) -> AddressIndex {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<AddressIndex>::wire2api(*wrap).into()
    }
}
impl Wire2Api<DatabaseConfig> for *mut wire_DatabaseConfig {
    fn wire2api(self) -> DatabaseConfig {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<DatabaseConfig>::wire2api(*wrap).into()
    }
}
impl Wire2Api<ElectrumConfig> for *mut wire_ElectrumConfig {
    fn wire2api(self) -> ElectrumConfig {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<ElectrumConfig>::wire2api(*wrap).into()
    }
}
impl Wire2Api<EsploraConfig> for *mut wire_EsploraConfig {
    fn wire2api(self) -> EsploraConfig {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<EsploraConfig>::wire2api(*wrap).into()
    }
}
impl Wire2Api<f32> for *mut f32 {
    fn wire2api(self) -> f32 {
        unsafe { *support::box_from_leak_ptr(self) }
    }
}
impl Wire2Api<LocalUtxo> for *mut wire_LocalUtxo {
    fn wire2api(self) -> LocalUtxo {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<LocalUtxo>::wire2api(*wrap).into()
    }
}
impl Wire2Api<PsbtSigHashType> for *mut wire_PsbtSigHashType {
    fn wire2api(self) -> PsbtSigHashType {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<PsbtSigHashType>::wire2api(*wrap).into()
    }
}
impl Wire2Api<RbfValue> for *mut wire_RbfValue {
    fn wire2api(self) -> RbfValue {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<RbfValue>::wire2api(*wrap).into()
    }
}
impl Wire2Api<Script> for *mut wire_Script {
    fn wire2api(self) -> Script {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<Script>::wire2api(*wrap).into()
    }
}
impl Wire2Api<SignOptions> for *mut wire_SignOptions {
    fn wire2api(self) -> SignOptions {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<SignOptions>::wire2api(*wrap).into()
    }
}
impl Wire2Api<SledDbConfiguration> for *mut wire_SledDbConfiguration {
    fn wire2api(self) -> SledDbConfiguration {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<SledDbConfiguration>::wire2api(*wrap).into()
    }
}
impl Wire2Api<SqliteDbConfiguration> for *mut wire_SqliteDbConfiguration {
    fn wire2api(self) -> SqliteDbConfiguration {
        let wrap = unsafe { support::box_from_leak_ptr(self) };
        Wire2Api::<SqliteDbConfiguration>::wire2api(*wrap).into()
    }
}
impl Wire2Api<u32> for *mut u32 {
    fn wire2api(self) -> u32 {
        unsafe { *support::box_from_leak_ptr(self) }
    }
}
impl Wire2Api<u64> for *mut u64 {
    fn wire2api(self) -> u64 {
        unsafe { *support::box_from_leak_ptr(self) }
    }
}
impl Wire2Api<u8> for *mut u8 {
    fn wire2api(self) -> u8 {
        unsafe { *support::box_from_leak_ptr(self) }
    }
}

impl Wire2Api<DatabaseConfig> for wire_DatabaseConfig {
    fn wire2api(self) -> DatabaseConfig {
        match self.tag {
            0 => DatabaseConfig::Memory,
            1 => unsafe {
                let ans = support::box_from_leak_ptr(self.kind);
                let ans = support::box_from_leak_ptr(ans.Sqlite);
                DatabaseConfig::Sqlite {
                    config: ans.config.wire2api(),
                }
            },
            2 => unsafe {
                let ans = support::box_from_leak_ptr(self.kind);
                let ans = support::box_from_leak_ptr(ans.Sled);
                DatabaseConfig::Sled {
                    config: ans.config.wire2api(),
                }
            },
            _ => unreachable!(),
        }
    }
}
impl Wire2Api<ElectrumConfig> for wire_ElectrumConfig {
    fn wire2api(self) -> ElectrumConfig {
        ElectrumConfig {
            url: self.url.wire2api(),
            socks5: self.socks5.wire2api(),
            retry: self.retry.wire2api(),
            timeout: self.timeout.wire2api(),
            stop_gap: self.stop_gap.wire2api(),
            validate_domain: self.validate_domain.wire2api(),
        }
    }
}
impl Wire2Api<EsploraConfig> for wire_EsploraConfig {
    fn wire2api(self) -> EsploraConfig {
        EsploraConfig {
            base_url: self.base_url.wire2api(),
            proxy: self.proxy.wire2api(),
            concurrency: self.concurrency.wire2api(),
            stop_gap: self.stop_gap.wire2api(),
            timeout: self.timeout.wire2api(),
        }
    }
}

impl Wire2Api<Vec<OutPoint>> for *mut wire_list_out_point {
    fn wire2api(self) -> Vec<OutPoint> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}
impl Wire2Api<Vec<ScriptAmount>> for *mut wire_list_script_amount {
    fn wire2api(self) -> Vec<ScriptAmount> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}
impl Wire2Api<LocalUtxo> for wire_LocalUtxo {
    fn wire2api(self) -> LocalUtxo {
        LocalUtxo {
            outpoint: self.outpoint.wire2api(),
            txout: self.txout.wire2api(),
            is_spent: self.is_spent.wire2api(),
            keychain: self.keychain.wire2api(),
        }
    }
}

impl Wire2Api<OutPoint> for wire_OutPoint {
    fn wire2api(self) -> OutPoint {
        OutPoint {
            txid: self.txid.wire2api(),
            vout: self.vout.wire2api(),
        }
    }
}
impl Wire2Api<PsbtSigHashType> for wire_PsbtSigHashType {
    fn wire2api(self) -> PsbtSigHashType {
        PsbtSigHashType {
            inner: self.inner.wire2api(),
        }
    }
}
impl Wire2Api<RbfValue> for wire_RbfValue {
    fn wire2api(self) -> RbfValue {
        match self.tag {
            0 => RbfValue::RbfDefault,
            1 => unsafe {
                let ans = support::box_from_leak_ptr(self.kind);
                let ans = support::box_from_leak_ptr(ans.Value);
                RbfValue::Value(ans.field0.wire2api())
            },
            _ => unreachable!(),
        }
    }
}
impl Wire2Api<Script> for wire_Script {
    fn wire2api(self) -> Script {
        Script {
            internal: self.internal.wire2api(),
        }
    }
}
impl Wire2Api<ScriptAmount> for wire_ScriptAmount {
    fn wire2api(self) -> ScriptAmount {
        ScriptAmount {
            script: self.script.wire2api(),
            amount: self.amount.wire2api(),
        }
    }
}
impl Wire2Api<SignOptions> for wire_SignOptions {
    fn wire2api(self) -> SignOptions {
        SignOptions {
            is_multi_sig: self.is_multi_sig.wire2api(),
            trust_witness_utxo: self.trust_witness_utxo.wire2api(),
            assume_height: self.assume_height.wire2api(),
            allow_all_sighashes: self.allow_all_sighashes.wire2api(),
            remove_partial_sigs: self.remove_partial_sigs.wire2api(),
            try_finalize: self.try_finalize.wire2api(),
            sign_with_tap_internal_key: self.sign_with_tap_internal_key.wire2api(),
            allow_grinding: self.allow_grinding.wire2api(),
        }
    }
}
impl Wire2Api<SledDbConfiguration> for wire_SledDbConfiguration {
    fn wire2api(self) -> SledDbConfiguration {
        SledDbConfiguration {
            path: self.path.wire2api(),
            tree_name: self.tree_name.wire2api(),
        }
    }
}
impl Wire2Api<SqliteDbConfiguration> for wire_SqliteDbConfiguration {
    fn wire2api(self) -> SqliteDbConfiguration {
        SqliteDbConfiguration {
            path: self.path.wire2api(),
        }
    }
}
impl Wire2Api<TxOut> for wire_TxOut {
    fn wire2api(self) -> TxOut {
        TxOut {
            value: self.value.wire2api(),
            script_pubkey: self.script_pubkey.wire2api(),
        }
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}

// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire___record__out_point_String_usize {
    field0: wire_OutPoint,
    field1: *mut wire_uint_8_list,
    field2: usize,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_ElectrumConfig {
    url: *mut wire_uint_8_list,
    socks5: *mut wire_uint_8_list,
    retry: u8,
    timeout: *mut u8,
    stop_gap: u64,
    validate_domain: bool,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_EsploraConfig {
    base_url: *mut wire_uint_8_list,
    proxy: *mut wire_uint_8_list,
    concurrency: *mut u8,
    stop_gap: u64,
    timeout: *mut u64,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_list_out_point {
    ptr: *mut wire_OutPoint,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_list_script_amount {
    ptr: *mut wire_ScriptAmount,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_LocalUtxo {
    outpoint: wire_OutPoint,
    txout: wire_TxOut,
    is_spent: bool,
    keychain: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_OutPoint {
    txid: *mut wire_uint_8_list,
    vout: u32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_PsbtSigHashType {
    inner: u32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_Script {
    internal: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_ScriptAmount {
    script: wire_Script,
    amount: u64,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_SignOptions {
    is_multi_sig: bool,
    trust_witness_utxo: bool,
    assume_height: *mut u32,
    allow_all_sighashes: bool,
    remove_partial_sigs: bool,
    try_finalize: bool,
    sign_with_tap_internal_key: bool,
    allow_grinding: bool,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_SledDbConfiguration {
    path: *mut wire_uint_8_list,
    tree_name: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_SqliteDbConfiguration {
    path: *mut wire_uint_8_list,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_TxOut {
    value: u64,
    script_pubkey: wire_Script,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_AddressIndex {
    tag: i32,
    kind: *mut AddressIndexKind,
}

#[repr(C)]
pub union AddressIndexKind {
    New: *mut wire_AddressIndex_New,
    LastUnused: *mut wire_AddressIndex_LastUnused,
    Peek: *mut wire_AddressIndex_Peek,
    Reset: *mut wire_AddressIndex_Reset,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_AddressIndex_New {}

#[repr(C)]
#[derive(Clone)]
pub struct wire_AddressIndex_LastUnused {}

#[repr(C)]
#[derive(Clone)]
pub struct wire_AddressIndex_Peek {
    index: u32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_AddressIndex_Reset {
    index: u32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_DatabaseConfig {
    tag: i32,
    kind: *mut DatabaseConfigKind,
}

#[repr(C)]
pub union DatabaseConfigKind {
    Memory: *mut wire_DatabaseConfig_Memory,
    Sqlite: *mut wire_DatabaseConfig_Sqlite,
    Sled: *mut wire_DatabaseConfig_Sled,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_DatabaseConfig_Memory {}

#[repr(C)]
#[derive(Clone)]
pub struct wire_DatabaseConfig_Sqlite {
    config: *mut wire_SqliteDbConfiguration,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_DatabaseConfig_Sled {
    config: *mut wire_SledDbConfiguration,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_RbfValue {
    tag: i32,
    kind: *mut RbfValueKind,
}

#[repr(C)]
pub union RbfValueKind {
    RbfDefault: *mut wire_RbfValue_RbfDefault,
    Value: *mut wire_RbfValue_Value,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_RbfValue_RbfDefault {}

#[repr(C)]
#[derive(Clone)]
pub struct wire_RbfValue_Value {
    field0: u32,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

impl NewWithNullPtr for wire___record__out_point_String_usize {
    fn new_with_null_ptr() -> Self {
        Self {
            field0: Default::default(),
            field1: core::ptr::null_mut(),
            field2: Default::default(),
        }
    }
}

impl Default for wire___record__out_point_String_usize {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl Default for wire_AddressIndex {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_AddressIndex {
    fn new_with_null_ptr() -> Self {
        Self {
            tag: -1,
            kind: core::ptr::null_mut(),
        }
    }
}

#[no_mangle]
pub extern "C" fn inflate_AddressIndex_Peek() -> *mut AddressIndexKind {
    support::new_leak_box_ptr(AddressIndexKind {
        Peek: support::new_leak_box_ptr(wire_AddressIndex_Peek {
            index: Default::default(),
        }),
    })
}

#[no_mangle]
pub extern "C" fn inflate_AddressIndex_Reset() -> *mut AddressIndexKind {
    support::new_leak_box_ptr(AddressIndexKind {
        Reset: support::new_leak_box_ptr(wire_AddressIndex_Reset {
            index: Default::default(),
        }),
    })
}

impl Default for wire_DatabaseConfig {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_DatabaseConfig {
    fn new_with_null_ptr() -> Self {
        Self {
            tag: -1,
            kind: core::ptr::null_mut(),
        }
    }
}

#[no_mangle]
pub extern "C" fn inflate_DatabaseConfig_Sqlite() -> *mut DatabaseConfigKind {
    support::new_leak_box_ptr(DatabaseConfigKind {
        Sqlite: support::new_leak_box_ptr(wire_DatabaseConfig_Sqlite {
            config: core::ptr::null_mut(),
        }),
    })
}

#[no_mangle]
pub extern "C" fn inflate_DatabaseConfig_Sled() -> *mut DatabaseConfigKind {
    support::new_leak_box_ptr(DatabaseConfigKind {
        Sled: support::new_leak_box_ptr(wire_DatabaseConfig_Sled {
            config: core::ptr::null_mut(),
        }),
    })
}

impl NewWithNullPtr for wire_ElectrumConfig {
    fn new_with_null_ptr() -> Self {
        Self {
            url: core::ptr::null_mut(),
            socks5: core::ptr::null_mut(),
            retry: Default::default(),
            timeout: core::ptr::null_mut(),
            stop_gap: Default::default(),
            validate_domain: Default::default(),
        }
    }
}

impl Default for wire_ElectrumConfig {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_EsploraConfig {
    fn new_with_null_ptr() -> Self {
        Self {
            base_url: core::ptr::null_mut(),
            proxy: core::ptr::null_mut(),
            concurrency: core::ptr::null_mut(),
            stop_gap: Default::default(),
            timeout: core::ptr::null_mut(),
        }
    }
}

impl Default for wire_EsploraConfig {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_LocalUtxo {
    fn new_with_null_ptr() -> Self {
        Self {
            outpoint: Default::default(),
            txout: Default::default(),
            is_spent: Default::default(),
            keychain: Default::default(),
        }
    }
}

impl Default for wire_LocalUtxo {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_OutPoint {
    fn new_with_null_ptr() -> Self {
        Self {
            txid: core::ptr::null_mut(),
            vout: Default::default(),
        }
    }
}

impl Default for wire_OutPoint {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_PsbtSigHashType {
    fn new_with_null_ptr() -> Self {
        Self {
            inner: Default::default(),
        }
    }
}

impl Default for wire_PsbtSigHashType {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl Default for wire_RbfValue {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_RbfValue {
    fn new_with_null_ptr() -> Self {
        Self {
            tag: -1,
            kind: core::ptr::null_mut(),
        }
    }
}

#[no_mangle]
pub extern "C" fn inflate_RbfValue_Value() -> *mut RbfValueKind {
    support::new_leak_box_ptr(RbfValueKind {
        Value: support::new_leak_box_ptr(wire_RbfValue_Value {
            field0: Default::default(),
        }),
    })
}

impl NewWithNullPtr for wire_Script {
    fn new_with_null_ptr() -> Self {
        Self {
            internal: core::ptr::null_mut(),
        }
    }
}

impl Default for wire_Script {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_ScriptAmount {
    fn new_with_null_ptr() -> Self {
        Self {
            script: Default::default(),
            amount: Default::default(),
        }
    }
}

impl Default for wire_ScriptAmount {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_SignOptions {
    fn new_with_null_ptr() -> Self {
        Self {
            is_multi_sig: Default::default(),
            trust_witness_utxo: Default::default(),
            assume_height: core::ptr::null_mut(),
            allow_all_sighashes: Default::default(),
            remove_partial_sigs: Default::default(),
            try_finalize: Default::default(),
            sign_with_tap_internal_key: Default::default(),
            allow_grinding: Default::default(),
        }
    }
}

impl Default for wire_SignOptions {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_SledDbConfiguration {
    fn new_with_null_ptr() -> Self {
        Self {
            path: core::ptr::null_mut(),
            tree_name: core::ptr::null_mut(),
        }
    }
}

impl Default for wire_SledDbConfiguration {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_SqliteDbConfiguration {
    fn new_with_null_ptr() -> Self {
        Self {
            path: core::ptr::null_mut(),
        }
    }
}

impl Default for wire_SqliteDbConfiguration {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

impl NewWithNullPtr for wire_TxOut {
    fn new_with_null_ptr() -> Self {
        Self {
            value: Default::default(),
            script_pubkey: Default::default(),
        }
    }
}

impl Default for wire_TxOut {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}

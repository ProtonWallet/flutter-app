#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
typedef struct _Dart_Handle* Dart_Handle;

typedef struct DartCObject DartCObject;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct wire_EsploraConfig {
  struct wire_uint_8_list *base_url;
  struct wire_uint_8_list *proxy;
  uint8_t *concurrency;
  uint64_t stop_gap;
  uint64_t *timeout;
} wire_EsploraConfig;

typedef struct wire_BlockchainConfig_Esplora {
  struct wire_EsploraConfig *config;
} wire_BlockchainConfig_Esplora;

typedef union BlockchainConfigKind {
  struct wire_BlockchainConfig_Esplora *Esplora;
} BlockchainConfigKind;

typedef struct wire_BlockchainConfig {
  int32_t tag;
  union BlockchainConfigKind *kind;
} wire_BlockchainConfig;

typedef struct wire_Script {
  struct wire_uint_8_list *internal;
} wire_Script;

typedef struct wire_ScriptAmount {
  struct wire_Script script;
  uint64_t amount;
} wire_ScriptAmount;

typedef struct wire_list_script_amount {
  struct wire_ScriptAmount *ptr;
  int32_t len;
} wire_list_script_amount;

typedef struct wire_OutPoint {
  struct wire_uint_8_list *txid;
  uint32_t vout;
} wire_OutPoint;

typedef struct wire_list_out_point {
  struct wire_OutPoint *ptr;
  int32_t len;
} wire_list_out_point;

typedef struct wire___record__out_point_String_usize {
  struct wire_OutPoint field0;
  struct wire_uint_8_list *field1;
  uintptr_t field2;
} wire___record__out_point_String_usize;

typedef struct wire_RbfValue_RbfDefault {

} wire_RbfValue_RbfDefault;

typedef struct wire_RbfValue_Value {
  uint32_t field0;
} wire_RbfValue_Value;

typedef union RbfValueKind {
  struct wire_RbfValue_RbfDefault *RbfDefault;
  struct wire_RbfValue_Value *Value;
} RbfValueKind;

typedef struct wire_RbfValue {
  int32_t tag;
  union RbfValueKind *kind;
} wire_RbfValue;

typedef struct wire_DatabaseConfig_Memory {

} wire_DatabaseConfig_Memory;

typedef struct wire_SqliteDbConfiguration {
  struct wire_uint_8_list *path;
} wire_SqliteDbConfiguration;

typedef struct wire_DatabaseConfig_Sqlite {
  struct wire_SqliteDbConfiguration *config;
} wire_DatabaseConfig_Sqlite;

typedef struct wire_SledDbConfiguration {
  struct wire_uint_8_list *path;
  struct wire_uint_8_list *tree_name;
} wire_SledDbConfiguration;

typedef struct wire_DatabaseConfig_Sled {
  struct wire_SledDbConfiguration *config;
} wire_DatabaseConfig_Sled;

typedef union DatabaseConfigKind {
  struct wire_DatabaseConfig_Memory *Memory;
  struct wire_DatabaseConfig_Sqlite *Sqlite;
  struct wire_DatabaseConfig_Sled *Sled;
} DatabaseConfigKind;

typedef struct wire_DatabaseConfig {
  int32_t tag;
  union DatabaseConfigKind *kind;
} wire_DatabaseConfig;

typedef struct wire_AddressIndex_New {

} wire_AddressIndex_New;

typedef struct wire_AddressIndex_LastUnused {

} wire_AddressIndex_LastUnused;

typedef struct wire_AddressIndex_Peek {
  uint32_t index;
} wire_AddressIndex_Peek;

typedef struct wire_AddressIndex_Reset {
  uint32_t index;
} wire_AddressIndex_Reset;

typedef union AddressIndexKind {
  struct wire_AddressIndex_New *New;
  struct wire_AddressIndex_LastUnused *LastUnused;
  struct wire_AddressIndex_Peek *Peek;
  struct wire_AddressIndex_Reset *Reset;
} AddressIndexKind;

typedef struct wire_AddressIndex {
  int32_t tag;
  union AddressIndexKind *kind;
} wire_AddressIndex;

typedef struct wire_SignOptions {
  bool is_multi_sig;
  bool trust_witness_utxo;
  uint32_t *assume_height;
  bool allow_all_sighashes;
  bool remove_partial_sigs;
  bool try_finalize;
  bool sign_with_tap_internal_key;
  bool allow_grinding;
} wire_SignOptions;

typedef struct wire_TxOut {
  uint64_t value;
  struct wire_Script script_pubkey;
} wire_TxOut;

typedef struct wire_LocalUtxo {
  struct wire_OutPoint outpoint;
  struct wire_TxOut txout;
  bool is_spent;
  int32_t keychain;
} wire_LocalUtxo;

typedef struct wire_PsbtSigHashType {
  uint32_t inner;
} wire_PsbtSigHashType;

typedef struct DartCObject *WireSyncReturn;

void store_dart_post_cobject(DartPostCObjectFnType ptr);

Dart_Handle get_dart_object(uintptr_t ptr);

void drop_dart_object(uintptr_t ptr);

uintptr_t new_dart_opaque(Dart_Handle handle);

intptr_t init_frb_dart_api_dl(void *obj);

void wire_create_blockchain__static_method__Api(int64_t port_,
                                                struct wire_BlockchainConfig *config);

void wire_get_height__static_method__Api(int64_t port_, struct wire_uint_8_list *blockchain_id);

void wire_get_blockchain_hash__static_method__Api(int64_t port_,
                                                  uint32_t blockchain_height,
                                                  struct wire_uint_8_list *blockchain_id);

void wire_estimate_fee__static_method__Api(int64_t port_,
                                           uint64_t target,
                                           struct wire_uint_8_list *blockchain_id);

void wire_broadcast__static_method__Api(int64_t port_,
                                        struct wire_uint_8_list *tx,
                                        struct wire_uint_8_list *blockchain_id);

void wire_create_transaction__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_tx_txid__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_weight__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_size__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_vsize__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_serialize_tx__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_is_coin_base__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_is_explicitly_rbf__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_is_lock_time_enabled__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_version__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_lock_time__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_input__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_output__static_method__Api(int64_t port_, struct wire_uint_8_list *tx);

void wire_serialize_psbt__static_method__Api(int64_t port_, struct wire_uint_8_list *psbt_str);

void wire_psbt_txid__static_method__Api(int64_t port_, struct wire_uint_8_list *psbt_str);

void wire_extract_tx__static_method__Api(int64_t port_, struct wire_uint_8_list *psbt_str);

void wire_psbt_fee_rate__static_method__Api(int64_t port_, struct wire_uint_8_list *psbt_str);

void wire_psbt_fee_amount__static_method__Api(int64_t port_, struct wire_uint_8_list *psbt_str);

void wire_combine_psbt__static_method__Api(int64_t port_,
                                           struct wire_uint_8_list *psbt_str,
                                           struct wire_uint_8_list *other);

void wire_json_serialize__static_method__Api(int64_t port_, struct wire_uint_8_list *psbt_str);

void wire_tx_builder_finish__static_method__Api(int64_t port_,
                                                struct wire_uint_8_list *wallet_id,
                                                struct wire_list_script_amount *recipients,
                                                struct wire_list_out_point *utxos,
                                                struct wire___record__out_point_String_usize *foreign_utxo,
                                                struct wire_list_out_point *unspendable,
                                                int32_t change_policy,
                                                bool manually_selected_only,
                                                float *fee_rate,
                                                uint64_t *fee_absolute,
                                                bool drain_wallet,
                                                struct wire_Script *drain_to,
                                                struct wire_RbfValue *rbf,
                                                struct wire_uint_8_list *data);

void wire_bump_fee_tx_builder_finish__static_method__Api(int64_t port_,
                                                         struct wire_uint_8_list *txid,
                                                         float fee_rate,
                                                         struct wire_uint_8_list *allow_shrinking,
                                                         struct wire_uint_8_list *wallet_id,
                                                         bool enable_rbf,
                                                         uint32_t *n_sequence);

void wire_create_descriptor__static_method__Api(int64_t port_,
                                                struct wire_uint_8_list *descriptor,
                                                int32_t network);

void wire_new_bip44_descriptor__static_method__Api(int64_t port_,
                                                   int32_t key_chain_kind,
                                                   struct wire_uint_8_list *secret_key,
                                                   int32_t network);

void wire_new_bip44_public__static_method__Api(int64_t port_,
                                               int32_t key_chain_kind,
                                               struct wire_uint_8_list *public_key,
                                               int32_t network,
                                               struct wire_uint_8_list *fingerprint);

void wire_new_bip49_descriptor__static_method__Api(int64_t port_,
                                                   int32_t key_chain_kind,
                                                   struct wire_uint_8_list *secret_key,
                                                   int32_t network);

void wire_new_bip49_public__static_method__Api(int64_t port_,
                                               int32_t key_chain_kind,
                                               struct wire_uint_8_list *public_key,
                                               int32_t network,
                                               struct wire_uint_8_list *fingerprint);

void wire_new_bip84_descriptor__static_method__Api(int64_t port_,
                                                   int32_t key_chain_kind,
                                                   struct wire_uint_8_list *secret_key,
                                                   int32_t network);

void wire_new_bip84_public__static_method__Api(int64_t port_,
                                               int32_t key_chain_kind,
                                               struct wire_uint_8_list *public_key,
                                               int32_t network,
                                               struct wire_uint_8_list *fingerprint);

void wire_descriptor_as_string_private__static_method__Api(int64_t port_,
                                                           struct wire_uint_8_list *descriptor,
                                                           int32_t network);

void wire_descriptor_as_string__static_method__Api(int64_t port_,
                                                   struct wire_uint_8_list *descriptor,
                                                   int32_t network);

void wire_max_satisfaction_weight__static_method__Api(int64_t port_,
                                                      struct wire_uint_8_list *descriptor,
                                                      int32_t network);

void wire_create_descriptor_secret__static_method__Api(int64_t port_,
                                                       int32_t network,
                                                       struct wire_uint_8_list *mnemonic,
                                                       struct wire_uint_8_list *password);

void wire_descriptor_secret_from_string__static_method__Api(int64_t port_,
                                                            struct wire_uint_8_list *secret);

void wire_extend_descriptor_secret__static_method__Api(int64_t port_,
                                                       struct wire_uint_8_list *secret,
                                                       struct wire_uint_8_list *path);

void wire_derive_descriptor_secret__static_method__Api(int64_t port_,
                                                       struct wire_uint_8_list *secret,
                                                       struct wire_uint_8_list *path);

void wire_descriptor_secret_as_secret_bytes__static_method__Api(int64_t port_,
                                                                struct wire_uint_8_list *secret);

void wire_descriptor_secret_as_public__static_method__Api(int64_t port_,
                                                          struct wire_uint_8_list *secret);

void wire_create_derivation_path__static_method__Api(int64_t port_, struct wire_uint_8_list *path);

void wire_descriptor_public_from_string__static_method__Api(int64_t port_,
                                                            struct wire_uint_8_list *public_key);

void wire_create_descriptor_public__static_method__Api(int64_t port_,
                                                       struct wire_uint_8_list *xpub,
                                                       struct wire_uint_8_list *path,
                                                       bool derive);

void wire_create_script__static_method__Api(int64_t port_,
                                            struct wire_uint_8_list *raw_output_script);

void wire_create_address__static_method__Api(int64_t port_, struct wire_uint_8_list *address);

void wire_address_from_script__static_method__Api(int64_t port_,
                                                  struct wire_Script *script,
                                                  int32_t network);

void wire_address_to_script_pubkey__static_method__Api(int64_t port_,
                                                       struct wire_uint_8_list *address);

void wire_payload__static_method__Api(int64_t port_, struct wire_uint_8_list *address);

void wire_address_network__static_method__Api(int64_t port_, struct wire_uint_8_list *address);

void wire_create_wallet__static_method__Api(int64_t port_,
                                            struct wire_uint_8_list *descriptor,
                                            struct wire_uint_8_list *change_descriptor,
                                            int32_t network,
                                            struct wire_DatabaseConfig *database_config);

void wire_get_address__static_method__Api(int64_t port_,
                                          struct wire_uint_8_list *wallet_id,
                                          struct wire_AddressIndex *address_index);

void wire_is_mine__static_method__Api(int64_t port_,
                                      struct wire_Script *script,
                                      struct wire_uint_8_list *wallet_id);

void wire_get_internal_address__static_method__Api(int64_t port_,
                                                   struct wire_uint_8_list *wallet_id,
                                                   struct wire_AddressIndex *address_index);

void wire_sync_wallet__static_method__Api(int64_t port_,
                                          struct wire_uint_8_list *wallet_id,
                                          struct wire_uint_8_list *blockchain_id);

void wire_get_balance__static_method__Api(int64_t port_, struct wire_uint_8_list *wallet_id);

void wire_list_unspent_outputs__static_method__Api(int64_t port_,
                                                   struct wire_uint_8_list *wallet_id);

void wire_get_transactions__static_method__Api(int64_t port_,
                                               struct wire_uint_8_list *wallet_id,
                                               bool include_raw);

void wire_sign__static_method__Api(int64_t port_,
                                   struct wire_uint_8_list *wallet_id,
                                   struct wire_uint_8_list *psbt_str,
                                   struct wire_SignOptions *sign_options);

void wire_wallet_network__static_method__Api(int64_t port_, struct wire_uint_8_list *wallet_id);

void wire_list_unspent__static_method__Api(int64_t port_, struct wire_uint_8_list *wallet_id);

void wire_get_psbt_input__static_method__Api(int64_t port_,
                                             struct wire_uint_8_list *wallet_id,
                                             struct wire_LocalUtxo *utxo,
                                             bool only_witness_utxo,
                                             struct wire_PsbtSigHashType *psbt_sighash_type);

void wire_get_descriptor_for_keychain__static_method__Api(int64_t port_,
                                                          struct wire_uint_8_list *wallet_id,
                                                          int32_t keychain);

void wire_generate_seed_from_word_count__static_method__Api(int64_t port_, int32_t word_count);

void wire_generate_seed_from_string__static_method__Api(int64_t port_,
                                                        struct wire_uint_8_list *mnemonic);

void wire_generate_seed_from_entropy__static_method__Api(int64_t port_,
                                                         struct wire_uint_8_list *entropy);

struct wire___record__out_point_String_usize *new_box_autoadd___record__out_point_String_usize_0(void);

struct wire_AddressIndex *new_box_autoadd_address_index_0(void);

struct wire_BlockchainConfig *new_box_autoadd_blockchain_config_0(void);

struct wire_DatabaseConfig *new_box_autoadd_database_config_0(void);

struct wire_EsploraConfig *new_box_autoadd_esplora_config_0(void);

float *new_box_autoadd_f32_0(float value);

struct wire_LocalUtxo *new_box_autoadd_local_utxo_0(void);

struct wire_PsbtSigHashType *new_box_autoadd_psbt_sig_hash_type_0(void);

struct wire_RbfValue *new_box_autoadd_rbf_value_0(void);

struct wire_Script *new_box_autoadd_script_0(void);

struct wire_SignOptions *new_box_autoadd_sign_options_0(void);

struct wire_SledDbConfiguration *new_box_autoadd_sled_db_configuration_0(void);

struct wire_SqliteDbConfiguration *new_box_autoadd_sqlite_db_configuration_0(void);

uint32_t *new_box_autoadd_u32_0(uint32_t value);

uint64_t *new_box_autoadd_u64_0(uint64_t value);

uint8_t *new_box_autoadd_u8_0(uint8_t value);

struct wire_list_out_point *new_list_out_point_0(int32_t len);

struct wire_list_script_amount *new_list_script_amount_0(int32_t len);

struct wire_uint_8_list *new_uint_8_list_0(int32_t len);

union AddressIndexKind *inflate_AddressIndex_Peek(void);

union AddressIndexKind *inflate_AddressIndex_Reset(void);

union BlockchainConfigKind *inflate_BlockchainConfig_Esplora(void);

union DatabaseConfigKind *inflate_DatabaseConfig_Sqlite(void);

union DatabaseConfigKind *inflate_DatabaseConfig_Sled(void);

union RbfValueKind *inflate_RbfValue_Value(void);

void free_WireSyncReturn(WireSyncReturn ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_create_blockchain__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_get_height__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_get_blockchain_hash__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_estimate_fee__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_broadcast__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_create_transaction__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_tx_txid__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_weight__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_size__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_vsize__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_serialize_tx__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_is_coin_base__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_is_explicitly_rbf__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_is_lock_time_enabled__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_version__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_lock_time__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_input__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_output__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_serialize_psbt__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_psbt_txid__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_extract_tx__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_psbt_fee_rate__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_psbt_fee_amount__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_combine_psbt__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_json_serialize__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_tx_builder_finish__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_bump_fee_tx_builder_finish__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_create_descriptor__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_new_bip44_descriptor__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_new_bip44_public__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_new_bip49_descriptor__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_new_bip49_public__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_new_bip84_descriptor__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_new_bip84_public__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_descriptor_as_string_private__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_descriptor_as_string__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_max_satisfaction_weight__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_create_descriptor_secret__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_descriptor_secret_from_string__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_extend_descriptor_secret__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_derive_descriptor_secret__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_descriptor_secret_as_secret_bytes__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_descriptor_secret_as_public__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_create_derivation_path__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_descriptor_public_from_string__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_create_descriptor_public__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_create_script__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_create_address__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_address_from_script__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_address_to_script_pubkey__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_payload__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_address_network__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_create_wallet__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_get_address__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_is_mine__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_get_internal_address__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_sync_wallet__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_get_balance__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_list_unspent_outputs__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_get_transactions__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_sign__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_wallet_network__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_list_unspent__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_get_psbt_input__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_get_descriptor_for_keychain__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_generate_seed_from_word_count__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_generate_seed_from_string__static_method__Api);
    dummy_var ^= ((int64_t) (void*) wire_generate_seed_from_entropy__static_method__Api);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd___record__out_point_String_usize_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_address_index_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_blockchain_config_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_database_config_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_esplora_config_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_f32_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_local_utxo_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_psbt_sig_hash_type_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_rbf_value_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_script_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_sign_options_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_sled_db_configuration_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_sqlite_db_configuration_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_u32_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_u64_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_u8_0);
    dummy_var ^= ((int64_t) (void*) new_list_out_point_0);
    dummy_var ^= ((int64_t) (void*) new_list_script_amount_0);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_0);
    dummy_var ^= ((int64_t) (void*) inflate_AddressIndex_Peek);
    dummy_var ^= ((int64_t) (void*) inflate_AddressIndex_Reset);
    dummy_var ^= ((int64_t) (void*) inflate_BlockchainConfig_Esplora);
    dummy_var ^= ((int64_t) (void*) inflate_DatabaseConfig_Sqlite);
    dummy_var ^= ((int64_t) (void*) inflate_DatabaseConfig_Sled);
    dummy_var ^= ((int64_t) (void*) inflate_RbfValue_Value);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturn);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}

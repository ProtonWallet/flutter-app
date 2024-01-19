use std::env;

// use lib_flutter_rust_bridge_codegen::{
//     config_parse, frb_codegen, get_symbols_if_no_duplicates, RawOpts,
// };

/// Path of input Rust code
const RUST_INPUT: &str = "src/rust_api.rs";
/// Path of output generated Dart code
const DART_OUTPUT: &str = "../lib/generated/bridge_bindings.dart";
const DARWIN_OUTPUT: &str = "./header/darwin/bridge_bindings.h";
const DECL_OUTPUT: &str = "../lib/generated/bridge_definitions.dart";

fn main() {
    // // Tell Cargo that if the input Rust code changes, to rerun this build script.
    // println!("cargo:rerun-if-changed={}", RUST_INPUT.to_string());
    // env::set_var("RUST_BACKTRACE", "full");
    // // Options for frb_codegen
    // let raw_opts = RawOpts {
    //     // Path of input Rust code
    //     rust_input: vec![RUST_INPUT.to_string()],
    //     // Path of output generated Dart code
    //     dart_output: vec![DART_OUTPUT.to_string()],

    //     // for other options use defaults
    //     wasm: false,
    //     dart_decl_output: Some(DECL_OUTPUT.into()),

    //     c_output: Some(vec![DARWIN_OUTPUT.to_string()]),
    //     inline_rust: true,
    //     dart_format_line_length: 120,

    //     // for other options use defaults
    //     ..Default::default()
    // };
    // // get opts from raw opts
    // let configs = config_parse(raw_opts);

    // // generation of rust api for ffi
    // let all_symbols = get_symbols_if_no_duplicates(&configs).unwrap();
    // for config in configs.iter() {
    //     frb_codegen(config, &all_symbols).unwrap();
    // }
}

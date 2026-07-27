include(FetchContent)

FetchContent_Declare(
    Corrosion
    GIT_REPOSITORY https://github.com/corrosion-rs/corrosion.git
    GIT_TAG v0.5.2 # Fix rustup v1.28+ `(active, default)` toolchain list format
)
FetchContent_MakeAvailable(Corrosion)

# Import targets defined in a package or workspace manifest `Cargo.toml` file
corrosion_import_crate(MANIFEST_PATH ../rust/Cargo.toml)

# Flutter-specific
set(CRATE_NAME "proton_wallet_common")
target_link_libraries(${BINARY_NAME} PUBLIC ${CRATE_NAME})

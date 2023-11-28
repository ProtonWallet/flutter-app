include(FetchContent)

FetchContent_Declare(
    Corrosion
    GIT_REPOSITORY https://github.com/corrosion-rs/corrosion.git
    GIT_TAG v0.4 # Optionally specify a commit hash, version tag or branch here
)
FetchContent_MakeAvailable(Corrosion)

# Import targets defined in a package or workspace manifest `Cargo.toml` file
corrosion_import_crate(MANIFEST_PATH ../rust/Cargo.toml)

# Flutter-specific
set(CRATE_NAME "proton_wallet_common")
target_link_libraries(${BINARY_NAME} PUBLIC ${CRATE_NAME})

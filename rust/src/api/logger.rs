use flutter_rust_bridge::frb;
use lazy_static::lazy_static;
use tracing::info;
use std::{env, sync::Mutex};
use tracing_appender::non_blocking::WorkerGuard;
use tracing_subscriber::layer::SubscriberExt;

use crate::common::logger::RotatingFileWriter;

lazy_static! {
    static ref LOG_GUARD: Mutex<Option<WorkerGuard>> = Mutex::new(None);
}

#[frb(sync)]
pub fn init_rust_logging(file_path: &str, file_name: &str) {
    // Set the RUST_LOG environment variable
    env::set_var("RUST_LOG", "trace");
    info!("Initializing Rust logging with file: {}", file_path);
    // Acquire the lock on LOG_GUARD
    let guard_check = LOG_GUARD.lock().unwrap();
    // Check if LOG_GUARD contains Some(WorkerGuard)
    if (guard_check.is_some()) {
        return;
    }
    drop(guard_check);

    // Create a rotating file writer
    let rotating_writer = RotatingFileWriter::new(file_path, file_name);
    let (file_writer, guard) = tracing_appender::non_blocking(rotating_writer);

    // Create a layer for logging to file
    let file_layer = tracing_subscriber::fmt::layer()
        .with_writer(file_writer)
        .with_ansi(false) // Disable ANSI colors in file logs
        .with_level(true);

    // Create a layer for logging to console
    let console_layer = tracing_subscriber::fmt::layer()
        .with_writer(std::io::stdout) // Console output
        .with_ansi(true) // Enable ANSI colors for console readability
        .with_level(true);

    // Set up a combined subscriber with both layers
    let subscriber = tracing_subscriber::registry()
        .with(file_layer)
        .with(console_layer);

    // Set the combined subscriber as the global default
    tracing::subscriber::set_global_default(subscriber).expect("Failed to set global subscriber");

    // Keep the guard alive to ensure file logs are flushed
    *LOG_GUARD.lock().unwrap() = Some(guard);

    info!("Initializing Rust logging with file: {}", file_path);
}

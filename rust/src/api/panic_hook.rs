use crate::frb_generated::StreamSink;
use flutter_rust_bridge::frb;
use std::panic;
use std::sync::Once;

static INIT: Once = Once::new();

/// Initialize the panic hook and send panic messages to Flutter
#[frb(sync)]
pub fn initialize_panic_hook(stream_sink: StreamSink<String>) {
    INIT.call_once(|| {
        panic::set_hook(Box::new(move |info| {
            let payload = match info.payload().downcast_ref::<&str>() {
                Some(message) => message.to_string(),
                None => "Unknown panic".to_string(),
            };

            let location = info
                .location()
                .map(|loc| format!("{}:{}:{}", loc.file(), loc.line(), loc.column()))
                .unwrap_or_else(|| "Unknown location".to_string());

            let panic_message = format!("Panic occurred: {}\nLocation: {}", payload, location);
            // Send panic message to Flutter
            stream_sink.add(panic_message).unwrap_or_else(|e| {
                eprintln!("Failed to send panic message to Flutter: {}", e);
            });
        }));
    });
}

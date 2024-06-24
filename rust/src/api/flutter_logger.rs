// flutter_logger.rs
use log::{info, LevelFilter};

pub fn test(i: i32) {
    info!("test called Log info!() with: {i}");
}
pub fn panic() {
    panic!("this should be passed to dart");
}

// macro without args creates init function "setup_log_stream" with LeveFilter::Debug
// you can also specify function name and LevelFilter (or only one)
// Only one of these macro calls can be active because of conflicting implementations

// flutter_logger::flutter_logger_init!(); // default
// flutter_logger::flutter_logger_init!(LeveFilter::Trace); // sepcify level
// flutter_logger::flutter_logger_init!(logger_init); // sepcify name
flutter_logger::flutter_logger_init!(info_logger, LevelFilter::Info); // sepcify both

use chrono::Local;
use tracing::{error, info};
use std::{
    fs::{File, OpenOptions},
    io::{self, Write},
    path::Path,
    sync::{Arc, Mutex},
};
use tracing_subscriber::fmt::MakeWriter;

// File size limit in bytes (50 MB)
const MAX_LOG_SIZE: u64 = 10 * 1024 * 1024;

pub(crate) struct RotatingFileWriter {
    file: Arc<Mutex<File>>,
    file_folder: String,
    file_path: String,
}

impl RotatingFileWriter {
    pub(crate) fn new(file_folder: &str, file_name: &str) -> Self {
        let file_path = format!("{}/{}", file_folder, file_name);
        let file = Arc::new(Mutex::new(
            Self::open_log_file(&file_path)
                .unwrap_or_else(|err| panic!("Failed to open initial log file: {:?}", err)),
        ));
        Self {
            file,
            file_folder: file_folder.to_string(),
            file_path,
        }
    }

    pub(crate) fn open_log_file(file_path: &str) -> io::Result<File> {
        OpenOptions::new()
            .create(true)
            .truncate(false)
            .append(true)
            .open(file_path)
    }

    pub(crate) fn check_file_size(&self) -> bool {
        match std::fs::metadata(&self.file_path) {
            Ok(metadata) => metadata.len() >= MAX_LOG_SIZE,
            Err(e) => {
                error!("Unable to read file metadata: {:?}", e);
                false
            }
        }
    }

    pub(crate) fn rotate_log_file(&self) {
        // Generate a rotated file name with a timestamp
        let rotated_file_path = self.generate_rotated_file_name();
        info!("Rotating log file to: {}", rotated_file_path);

        // Attempt to rename the file and handle errors
        if let Err(e) = std::fs::rename(&self.file_path, &rotated_file_path) {
            info!("Failed to rotate log file: {:?}", e);
            return;
        }

        // Open a new log file with the original name and handle errors
        match Self::open_log_file(&self.file_path) {
            Ok(new_file) => {
                let mut file_lock = self.file.lock().unwrap();
                *file_lock = new_file;
            }
            Err(e) => {
                info!("Failed to open new log file after rotation: {:?}", e);
            }
        }
    }

    pub(crate) fn generate_rotated_file_name(&self) -> String {
        let timestamp = Local::now().format("%Y%m%d%H%M%S").to_string();
        let extension = Path::new(&self.file_path)
            .extension()
            .and_then(|e| e.to_str())
            .unwrap_or("");
        let base_name = Path::new(&self.file_path)
            .file_stem()
            .and_then(|stem| stem.to_str())
            .unwrap_or("log");
        if extension.is_empty() {
            format!("{}/{}_{}.log", self.file_folder, base_name, timestamp)
        } else {
            format!(
                "{}/{}_{}.{}",
                self.file_folder, base_name, timestamp, extension
            )
        }
    }
}

impl Write for RotatingFileWriter {
    fn write(&mut self, buf: &[u8]) -> io::Result<usize> {
        let mut file = self.file.lock().unwrap();
        let bytes_written = file.write(buf)?;
        let check = self.check_file_size();
        if check {
            info!("Start rotate_log_file");
            // Close the current file by unlocking it
            drop(file);
            self.rotate_log_file();
        }
        Ok(bytes_written)
    }

    fn flush(&mut self) -> io::Result<()> {
        let mut file = self.file.lock().unwrap();
        file.flush()
    }
}

impl<'a> MakeWriter<'a> for RotatingFileWriter {
    type Writer = RotatingFileWriter;

    fn make_writer(&'a self) -> Self::Writer {
        RotatingFileWriter {
            file: Arc::clone(&self.file),
            file_path: self.file_path.clone(),
            file_folder: self.file_folder.clone(),
        }
    }
}

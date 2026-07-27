use std::sync::{Mutex, MutexGuard};

static PGP_GLOBAL_LOCK: Mutex<()> = Mutex::new(());

/// Serializes all gopenpgp (Go) calls.
///
/// The Go runtime linked via `gopenpgp-sys` is not safe for concurrent use from
/// multiple OS threads. Concurrent FRB thread-pool calls can trigger
/// `EXC_BAD_ACCESS` inside Go's signal handler on iOS debug builds.
#[inline]
pub fn pgp_global_lock() -> MutexGuard<'static, ()> {
    PGP_GLOBAL_LOCK
        .lock()
        .unwrap_or_else(std::sync::PoisonError::into_inner)
}

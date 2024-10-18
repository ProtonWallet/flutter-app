use std::{future::Future, pin::Pin};

pub trait Migration: Send + Sync {
    fn start_version(&self) -> u32;
    fn end_version(&self) -> u32;

    fn migrate(&self) -> impl std::future::Future<Output = ()> + Send;
}
pub struct SimpleMigration {
    start_version: u32,
    end_version: u32,
    migrate_fn: Box<dyn Fn() -> Pin<Box<dyn Future<Output = ()> + Send>> + Send + Sync>,
}

impl SimpleMigration {
    pub fn new<F, Fut>(start_version: u32, end_version: u32, migrate_fn: F) -> Self
    where
        F: Fn() -> Fut + Send + Sync + 'static,
        Fut: Future<Output = ()> + Send + 'static,
    {
        SimpleMigration {
            start_version,
            end_version,
            migrate_fn: Box::new(move || {
                let fut = migrate_fn();
                Box::pin(fut) as Pin<Box<dyn Future<Output = ()> + Send>>
            }),
        }
    }
}

impl std::fmt::Debug for SimpleMigration {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("SimpleMigration")
            .field("start_version", &self.start_version)
            .field("end_version", &self.end_version)
            .finish()
    }
}

impl Migration for SimpleMigration {
    fn start_version(&self) -> u32 {
        self.start_version
    }

    fn end_version(&self) -> u32 {
        self.end_version
    }

    async fn migrate(&self) {
        (self.migrate_fn)().await;
    }
}

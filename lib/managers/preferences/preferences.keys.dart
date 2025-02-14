class PreferenceKeys {
  static const String eventLoopErrorCount =
      "proton_wallet_app_k_event_loop_error_count";
  static const String syncErrorCount = "proton_wallet_app_k_sync_error_count";
  static const String syncErrorTimer = "proton_wallet_app_k_sync_error_timmer";

  static const String bdkFullSyncedPrefix = "is_bdk_wallet_full_synced";
  static const String latestEventId = "latest_event_id";
  static const String appDatabaseVersion = "appDatabaseVersion";

  static const String displayBalanceKey = "user.settings.displayBalance";
  static const String customStopgapKey = "user.settings.custom.stopgap";

  static const String appDatabaseForceVersion = "app_database_force_version";
  static const String appDatabaseSqliteForceVersion =
      "app_database_sqlite_force_version";
  static const String appBDKDatabaseForceVersion =
      "app_bdk_database_force_version";

  static const String inAppReviewTimmer = "home.in.app.review.timmer_key";
  static const String inAppReviewDetailCounter =
      "home.in.app.review.details.counter_key";
}

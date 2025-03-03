part of 'settings.view.dart';

/// this is experimental code.
mixin SettingsViewMixin {
  Column buildDebugSection(SettingsViewModel viewModel) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const SectionHeader(title: 'Dev Tools'),
        SettingsGroup(
          children: [
            SettingsItem(
              title: "Test Sentry crashes",
              onTap: () {
                /// Trigger a crash for testing
                throw Exception(
                    'This is a test crash for Sentry from flutter dart.');
              },
            ),
            SettingsItem(
              title: "Sentry send exception",
              onTap: () {
                try {
                  throw Exception(
                      'This is a test catched exception then sent to sentry from flutter dart.');
                } catch (e, stacktrace) {
                  Sentry.captureException(
                    e,
                    stackTrace: stacktrace,
                  );
                }
              },
            ),
            SettingsItem(
              title: "Debug Button",
              onTap: () {
                viewModel.toDebugView();
              },
            ),
          ],
        ),
        const SizedBox(height: 36),
      ],
    );
  }
}

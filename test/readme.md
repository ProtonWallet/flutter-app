# test root

test/
  integration/
    integration_test1.dart
    integration_test2.dart
  compatibility/
    compatibility_test1.dart
    compatibility_test2.dart
  e2e/
    e2e_test1.dart
    e2e_test2.dart
  other foders must match with `lib`

the folders under tests must be matches with lib folder. by default test types are unit tests for logical code and widget(UI) test for widgets

## folders no in lib

### compatibility

Ensure that your app works across different environments, devices, or configurations. These tests may overlap with both integration and E2E tests but are focused on cross-platform consistency.

### e2e

End-to-End (E2E) Tests. Simulate real user scenarios by testing the entire application from start to finish, often involving UI interactions.

### integration

Focus on testing how different parts of your application work together. They typically involve testing multiple components but do not necessarily involve the entire app or UI.

### snapshot

prerender the screens and compare with runtime mostly test Scenes

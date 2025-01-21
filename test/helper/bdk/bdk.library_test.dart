import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../helper.dart';
import '../../mocks/path.provider.mocks.dart';

/// NOTE: Top-level functions cannot be directly mocked.
/// Consider refactoring code that uses top-level functions so they are injected as dependencies.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('_getDatabaseFolder and getDatabaseFolderPath', () {
    setUp(() {});

    testUnit('mock getApplicationDocumentsDirectory', () async {
      final mockPahtProvider = MockTestPathProviderPlatform();
      PathProviderPlatform.instance = mockPahtProvider;
      when(mockPahtProvider.getApplicationDocumentsPath())
          .thenAnswer((_) async {
        return '/mock/app/documents';
      });

      // Call the mocked function
      final result = await getApplicationDocumentsDirectory();
      // Assert the path
      expect(result.path, '/mock/app/documents');
    });
    testUnit('should create the database folder if not exist', () async {
      final mockPahtProvider = MockTestPathProviderPlatform();
      PathProviderPlatform.instance = mockPahtProvider;
      when(mockPahtProvider.getApplicationDocumentsPath())
          .thenAnswer((_) async {
        return '/mock/app/documents';
      });

      final mockDirectory = MockDirectory();
      // Mock directory behavior
      final dbPath = '/mock/app/documents/databases';
      when(mockDirectory.path).thenReturn(dbPath);
      when(mockDirectory.existsSync()).thenReturn(false);
      when(mockDirectory.createSync(recursive: true));
    });
  });
}

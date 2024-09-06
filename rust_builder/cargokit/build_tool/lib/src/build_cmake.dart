/// This is copied from Cargokit (which is the official way to use it currently)
/// Details: https://fzyzcjy.github.io/flutter_rust_bridge/manual/integrate/builtin

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'artifacts_provider.dart';
import 'builder.dart';
import 'environment.dart';
import 'options.dart';
import 'target.dart';

final log = Logger('build_cmake');

class BuildCMake {
  final CargokitUserOptions userOptions;

  BuildCMake({required this.userOptions});

  Future<void> build() async {
    final targetPlatform = Environment.targetPlatform;
    final target = Target.forFlutterName(Environment.targetPlatform);
    if (target == null) {
      throw Exception("Unknown target platform: $targetPlatform");
    }

    final environment = BuildEnvironment.fromEnvironment(isAndroid: false);
    final provider =
        ArtifactProvider(environment: environment, userOptions: userOptions);
    final artifacts = await provider.getArtifacts([target]);

    final libs = artifacts[target]!;
    final outputDir = Environment.outputDir;
    for (final lib in libs) {
      if (lib.type == AritifactType.dylib) {
        // File(lib.path)
        //     .copySync(path.join(Environment.outputDir, lib.finalFileName));
        final directory = File(lib.path).parent;
        final soFiles = directory.listSync().where((entity) =>
            entity is File &&
            (entity.path.endsWith('.so') || entity.path.endsWith('.dll')));
        for (var entity in soFiles) {
          var file = entity as File;
          var fileName = path.basename(file.path);
          var destinationPath = path.join(outputDir, fileName);
          file.copySync(destinationPath);
          log.info('Copied ${file.path} to $destinationPath');
        }
      }
    }
  }
}

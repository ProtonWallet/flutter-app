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

final log = Logger('build_gradle');

class BuildGradle {
  BuildGradle({required this.userOptions});

  final CargokitUserOptions userOptions;

  Future<void> build() async {
    final targets = Environment.targetPlatforms.map((arch) {
      final target = Target.forFlutterName(arch);
      if (target == null) {
        throw Exception(
            "Unknown darwin target or platform: $arch, ${Environment.darwinPlatformName}");
      }
      return target;
    }).toList();

    final environment = BuildEnvironment.fromEnvironment(isAndroid: true);
    final provider =
        ArtifactProvider(environment: environment, userOptions: userOptions);
    final artifacts = await provider.getArtifacts(targets);

    for (final target in targets) {
      final libs = artifacts[target]!;
      final outputDir = path.join(Environment.outputDir, target.android!);
      Directory(outputDir).createSync(recursive: true);
      log.info("Output:  $outputDir");
      for (final lib in libs) {
        if (lib.type == AritifactType.dylib) {
          // workaround with gopenpgp-sys
          //File(lib.path).copySync(path.join(outputDir, "libgopenpgp-sys.so"));
          //File(lib.path).copySync(path.join(outputDir, lib.finalFileName));
          final directory = File(lib.path).parent;
          final soFiles = directory
              .listSync()
              .where((entity) => entity is File && entity.path.endsWith('.so'));
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
}

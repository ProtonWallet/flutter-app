import 'dart:io';

import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class TestPathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {}

@GenerateMocks([Directory, File, Logger, TestPathProviderPlatform])
void main() {}

import 'package:wallet/managers/channels/native.view.channel.dart';

abstract class PlatformChannelManager {
  NativeViewChannel get nativeViewChannel;
  Future<void> init();
}

class PlatformChannelManagerImpl implements PlatformChannelManager {
  late NativeViewChannel _nativeViewChannel;

  @override
  NativeViewChannel get nativeViewChannel => _nativeViewChannel;

  @override
  Future<void> init() async {
    _nativeViewChannel = NativeViewChannelImpl();
  }
}

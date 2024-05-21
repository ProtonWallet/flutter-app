import 'package:equatable/equatable.dart';
import 'package:wallet/managers/channels/platform.channel.state.dart';

abstract class ChannelEvent extends Equatable {
  const ChannelEvent();
}

class DirectEmitEvent extends ChannelEvent {
  final NativeLoginSucess newState;
  const DirectEmitEvent(this.newState);
  @override
  List<Object> get props => [newState];
}

class LoadData extends ChannelEvent {
  @override
  List<Object> get props => [];
}

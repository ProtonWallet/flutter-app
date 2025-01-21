import 'package:equatable/equatable.dart';
import 'package:wallet/managers/channels/platform.channel.state.dart';

abstract class UserManagerEvent extends Equatable {
  const UserManagerEvent();
}

class DirectEmitEvent extends UserManagerEvent {
  final NativeLoginSuccess newState;
  const DirectEmitEvent(this.newState);
  @override
  List<Object> get props => [newState];
}

class LoadData extends UserManagerEvent {
  @override
  List<Object> get props => [];
}

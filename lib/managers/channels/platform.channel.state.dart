// Data States
import 'package:equatable/equatable.dart';
import 'package:wallet/models/native.session.model.dart';

abstract class NativeLoginState extends Equatable {
  const NativeLoginState();
}

class NativeLoginInitial extends NativeLoginState {
  @override
  List<Object> get props => [];
}

class NativeLoginSucess extends NativeLoginState {
  final UserInfo userInfo;
  const NativeLoginSucess(this.userInfo);
  @override
  List<Object> get props => [userInfo];
}

class NativeLoginError extends NativeLoginState {
  final String error;
  const NativeLoginError(this.error);
  @override
  List<Object> get props => [error];
}

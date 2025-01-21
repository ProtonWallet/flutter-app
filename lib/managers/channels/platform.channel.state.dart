// Data States
import 'package:equatable/equatable.dart';
import 'package:wallet/models/native.session.model.dart';
import 'package:wallet/rust/proton_api/auth_credential.dart';

abstract class NativeLoginState extends Equatable {
  const NativeLoginState();
}

class NativeLoginInitial extends NativeLoginState {
  @override
  List<Object> get props => [];
}

class NativeLoginSuccess extends NativeLoginState {
  final UserInfo userInfo;
  const NativeLoginSuccess(this.userInfo);
  @override
  List<Object> get props => [userInfo];
}

class FlutterLoginSucess extends NativeLoginState {
  final AuthCredential authCredential;
  const FlutterLoginSucess(this.authCredential);
  @override
  List<Object> get props => [authCredential];
}

class NativeLoginError extends NativeLoginState {
  final String error;
  const NativeLoginError(this.error);
  @override
  List<Object> get props => [error];
}

// Data States
import 'package:equatable/equatable.dart';

abstract class UserManagerState extends Equatable {
  const UserManagerState();
}

class UserManagerInitial extends UserManagerState {
  @override
  List<Object> get props => [];
}

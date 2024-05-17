import 'package:freezed_annotation/freezed_annotation.dart';

part 'native.session.model.g.dart';

@JsonSerializable()
class NativeSession {
  String userId;
  String sessionId;
  String userName;
  String passphrase;
  String accessToken;
  String refreshToken;

  NativeSession({
    required this.userId,
    required this.sessionId,
    required this.userName,
    required this.passphrase,
    required this.accessToken,
    required this.refreshToken,
  });

  /// Connect the generated [_$NativeSessionFromJson] function to the `fromJson`
  /// factory.
  factory NativeSession.fromJson(Map<String, dynamic> json) =>
      _$NativeSessionFromJson(json);

  /// Connect the generated [_$NativeSessionToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$NativeSessionToJson(this);
}

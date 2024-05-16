import 'package:freezed_annotation/freezed_annotation.dart';

part 'native.session.model.g.dart';

@JsonSerializable()
class NativeSession {
  String UserId;
  String SessionId;
  String Username;
  String Passphrase;
  String AccessToken;
  String RefreshToken;

  NativeSession({
    required this.UserId,
    required this.SessionId,
    required this.Username,
    required this.Passphrase,
    required this.AccessToken,
    required this.RefreshToken,
  });

  /// Connect the generated [_$NativeSessionFromJson] function to the `fromJson`
  /// factory.
  factory NativeSession.fromJson(Map<String, dynamic> json) =>
      _$NativeSessionFromJson(json);

  /// Connect the generated [_$NativeSessionToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$NativeSessionToJson(this);
}

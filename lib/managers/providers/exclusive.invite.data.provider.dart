import 'dart:async';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/api/api_service/invite_client.dart';
import 'package:wallet/rust/proton_api/invite.dart';

class AvailableUpdated extends DataUpdated<RemainingMonthlyInvitations> {
  AvailableUpdated(
      {required RemainingMonthlyInvitations remainingMonthlyInvitations})
      : super(remainingMonthlyInvitations);
}

class ExclusiveInviteDataProvider extends DataProvider {
  RemainingMonthlyInvitations? _remainingMonthlyInvitations;
  final InviteClient inviteClient;

  ExclusiveInviteDataProvider(
    this.inviteClient,
  );

  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  Future<void> updateData() async {
    final remainingMonthlyInvitations =
        await inviteClient.getRemainingMonthlyInvitation();
    if (remainingMonthlyInvitations.available !=
        (_remainingMonthlyInvitations?.available ?? 0)) {
      _remainingMonthlyInvitations = remainingMonthlyInvitations;
      emitState(AvailableUpdated(
          remainingMonthlyInvitations: remainingMonthlyInvitations));
    }
  }

  Future<void> preLoad() async {
    await updateData();
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}

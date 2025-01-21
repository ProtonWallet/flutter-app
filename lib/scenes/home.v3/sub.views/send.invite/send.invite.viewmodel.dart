import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/send.invite/send.invite.coordinator.dart';

enum SendInviteState {
  sendInvite,
  sendInviteSuccess,
}

abstract class SendInviteViewModel extends ViewModel<SendInviteCoordinator> {
  late List<ProtonAddress> userAddresses;
  late List<ContactsModel> contactsEmails;

  late TextEditingController emailController;
  late ValueNotifier userAddressValueNotifier;

  bool initialized = false;
  SendInviteState state = SendInviteState.sendInvite;

  Future<bool> sendExclusiveInvite(ProtonAddress protonAddress, String email);

  void updateState(SendInviteState state);

  SendInviteViewModel(
    super.coordinator,
  );
}

class SendInviteViewModelImpl extends SendInviteViewModel {
  final ProtonApiServiceManager apiServiceManager;
  final DataProviderManager dataProviderManager;
  final AppStateManager appStateManager;

  SendInviteViewModelImpl(
    super.coordinator,
    this.apiServiceManager,
    this.dataProviderManager,
    this.appStateManager,
  );

  @override
  Future<bool> sendExclusiveInvite(
      ProtonAddress protonAddress, String email) async {
    final String emailAddressID = protonAddress.id;
    try {
      await apiServiceManager
          .getApiService()
          .getInviteClient()
          .sendNewcomerInvite(
            inviteeEmail: email.trim(),
            inviterAddressId: emailAddressID,
          );
      dataProviderManager.exclusiveInviteDataProvider.updateData();
    } on BridgeError catch (e) {
      appStateManager.updateStateFrom(e);
      final errMsg = parseSampleDisplayError(e);
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        CommonHelper.showErrorDialog(errMsg);
      }
      return false;
    } catch (e) {
      final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        CommonHelper.showErrorDialog(e.toString());
      }
      return false;
    }
    return true;
  }

  @override
  Future<void> loadData() async {
    /// preload data
    await loadContacts();
    await loadProtonAddresses();

    /// init UI controller and notifier
    emailController = TextEditingController(text: "");
    userAddressValueNotifier = ValueNotifier(userAddresses.firstOrNull);

    if (userAddresses.isNotEmpty) {
      initialized = true;
    }
    sinkAddSafe();
  }

  Future<void> loadContacts() async {
    await dataProviderManager.contactsDataProvider.preLoad();
    contactsEmails =
        await dataProviderManager.contactsDataProvider.getContacts() ?? [];
  }

  Future<void> loadProtonAddresses() async {
    try {
      userAddresses =
          await dataProviderManager.addressKeyProvider.getAddresses();
    } catch (e) {
      logger.e(e.toString());
    }
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  void updateState(SendInviteState state) {
    this.state = state;
    sinkAddSafe();
  }
}

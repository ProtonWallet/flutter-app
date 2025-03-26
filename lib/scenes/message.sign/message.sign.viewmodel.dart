import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/message_signer.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/common/signing_type.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/message.sign/message.sign.coordinator.dart';

abstract class MessageSignViewModel extends ViewModel<MessageSignCoordinator> {
  MessageSignViewModel(super.coordinator, this.address);

  final String address;
  final messageController = TextEditingController();
  final signatureController = TextEditingController();

  bool get showSignature;
  bool get isLoading;
  String get signature;

  Future<bool> signMessage(SigningType signingType);
}

class MessageSignViewModelImpl extends MessageSignViewModel {
  final FrbAccount account;

  MessageSignViewModelImpl(
    super.coordinator,
    super.address,
    this.account,
  );

  bool _isLoading = false;
  bool _showSignature = false;

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      default:
        break;
    }
  }

  @override
  Future<bool> signMessage(SigningType signingType) async {
    _isLoading = true;
    sinkAddSafe();
    final message = messageController.text;
    final signer = FrbMessageSigner();
    try {
      // sign message
      final result = await signer.signMessage(
          account: account,
          signingType: signingType,
          message: message,
          btcAddress: address);
      // set signature
      signatureController.text = result;
      // verify signature
      await signer.verifyMessage(
          account: account,
          message: message,
          signature: result,
          btcAddress: address);
      _isLoading = false;
      _showSignature = true;
      sinkAddSafe();
      return true;
    } on BridgeError catch (e, stacktrace) {
      _isLoading = false;
      sinkAddSafe();
      Sentry.captureException(e, stackTrace: stacktrace);
    } catch (e) {
      _isLoading = false;
      sinkAddSafe();
    }

    return false;
  }

  @override
  bool get isLoading => _isLoading;
  @override
  bool get showSignature => _showSignature;
  @override
  String get signature => signatureController.text;
}

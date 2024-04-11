import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class MailEditViewModel extends ViewModel {
  MailEditViewModel(super.coordinator, this.mailSettingID);
  final int mailSettingID;
  late ValueNotifier linkWalletNotifier;
  late TextEditingController mailController;
  late TextEditingController minAmountController;
  late TextEditingController maxAmountController;
  late TextEditingController minCoinController;
  late TextEditingController maxCoinController;
}

class MailEditViewModelImpl extends MailEditViewModel {
  MailEditViewModelImpl(super.coordinator, super.mailSettingID);
  final datasourceChangedStreamController =
      StreamController<MailEditViewModel>.broadcast();
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    linkWalletNotifier = ValueNotifier("Select wallet");
    minCoinController = TextEditingController();
    maxCoinController = TextEditingController();
    minAmountController = TextEditingController();
    maxAmountController = TextEditingController();
    mailController = TextEditingController();
    mailController.text = "1234567@proton.me";
    linkWalletNotifier.addListener(() {
      datasourceChangedStreamController.sink.add(this);
    });
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void move(NavigationIdentifier to) {}
}

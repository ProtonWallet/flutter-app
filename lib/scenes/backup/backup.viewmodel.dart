import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:wallet/generated/bridge_definitions.dart';
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class SetupBackupViewModel extends ViewModel {
  SetupBackupViewModel(super.coordinator);

  List<Item> itemList = [];
}

class SetupBackupViewModelImpl extends SetupBackupViewModel {
  SetupBackupViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<SetupBackupViewModel>.broadcast();
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    var mnemonic = await Mnemonic.create(WordCount.Words12);
    var strMnemonic = mnemonic.asString();
    strMnemonic.split(" ").forEachIndexed((index, element) {
      itemList.add(Item(
        title: element,
        index: index,
      ));
    });
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;
}

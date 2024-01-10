import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class SetupBackupViewModel extends ViewModel {
  SetupBackupViewModel(super.coordinator, this.strMnemonic);

  List<Item> itemList = [];
  List<Item> itemListShuffled = [];
  String strMnemonic;
  int editIndex = 0;
  bool isVerifyingUserMnemonic = false;
  List verifiedIndex = [0, 11];

  bool checkUserMnemonic();

  List<int> tappedIndices = [];

  void updateTag(int index);

  void updateState(bool isVerifyingUserMnemonic);
}

class SetupBackupViewModelImpl extends SetupBackupViewModel {
  SetupBackupViewModelImpl(super.coordinator, super.strMnemonic);

  final datasourceChangedStreamController =
      StreamController<SetupBackupViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    strMnemonic.split(" ").forEachIndexed((index, element) {
      itemList.add(Item(
        title: element,
        index: index,
      ));
    });
    itemListShuffled = itemList
        .map((item) => Item(title: item.title, index: 0, active: false))
        .toList();
    itemListShuffled.shuffle();
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  bool checkUserMnemonic() {
    if (tappedIndices.length == verifiedIndex.length) {
      for (int i = 0; i < tappedIndices.length; i++) {
        if (itemListShuffled[tappedIndices[i]].title !=
            itemList[verifiedIndex[i]].title) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  void updateState(bool isVerifyingUserMnemonic) {
    this.isVerifyingUserMnemonic = isVerifyingUserMnemonic;
    datasourceChangedStreamController.add(this);
  }

  @override
  void updateTag(int index) {
    if (itemListShuffled[index].active == false) {
      if (tappedIndices.length < verifiedIndex.length) {
        tappedIndices.add(index);
      }
    } else {
      itemListShuffled[index] =
          Item(title: itemListShuffled[index].title, index: 0, active: false);
      tappedIndices.removeWhere((element) => element == index);
    }
    for (int i = 0; i < tappedIndices.length; i++) {
      int index = tappedIndices[i];
      itemListShuffled[index] = Item(
          title: itemListShuffled[index].title,
          index: verifiedIndex[i] + 1,
          active: true);
    }
    datasourceChangedStreamController.add(this);
  }
}

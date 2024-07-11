import 'dart:async';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/api/api_service/block_client.dart';

class BlockInfoDataProvider extends DataProvider {
  final BlockClient blockClient;
  int blockHeight = 0;

  BlockInfoDataProvider(
    this.blockClient,
  );

  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  Future<void> syncBlockHeight() async {
    int newHeight = await blockClient.getTipHeight();
    if (newHeight > blockHeight) {
      blockHeight = newHeight;
      dataUpdateController.add(DataUpdated("Block height updated!"));
    }
  }

  Future<void> preLoad() async {
    blockHeight = await blockClient.getTipHeight();
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}

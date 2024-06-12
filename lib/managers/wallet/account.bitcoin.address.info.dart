import 'dart:math';

class CachedAccountBitcoinAddressInfo {
  Map<String, int> bitcoinAddressIndexMap =
      {}; // key: bitcoinAddress, value: bitcoinAddressIndex
  int highestUsedIndex = 0;

  void updateHighestUsedIndex(int index) {
    highestUsedIndex = max(highestUsedIndex, index);
  }
}

class FeeRate {
  final double _feeRate;
  FeeRate._(this._feeRate);

  double asSatPerVb() {
    return _feeRate;
  }
}

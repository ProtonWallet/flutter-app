import 'package:flutter/material.dart';
import 'package:wallet/rust/api/bdk_wallet/address.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/scenes/components/btc.address/bitcoin.address.info.box.dart';

class WalletBitcoinAddressList extends StatefulWidget {
  final List<FrbAddressDetails> addresses;
  final List<String> addressesInPool;
  final ProtonExchangeRate exchangeRate;
  final ShowTransactionDetailCallback showTransactionDetailCallback;
  final ShowAddressQRcodeCallback showAddressQRcodeCallback;
  final OnSigningCallback onSigningCallback;
  final bool showMessageSigner;

  const WalletBitcoinAddressList({
    required this.addresses,
    required this.addressesInPool,
    required this.exchangeRate,
    required this.showTransactionDetailCallback,
    required this.showAddressQRcodeCallback,
    required this.onSigningCallback,
    required this.showMessageSigner,
    super.key,
  });

  @override
  WalletBitcoinAddressListState createState() =>
      WalletBitcoinAddressListState();
}

class WalletBitcoinAddressListState extends State<WalletBitcoinAddressList> {
  @override
  void didUpdateWidget(WalletBitcoinAddressList oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final address in widget.addresses)
          BitcoinAddressInfoBox(
            bitcoinAddressDetail: address,
            exchangeRate: widget.exchangeRate,
            showTransactionDetailCallback: widget.showTransactionDetailCallback,
            showAddressQRcodeCallback: widget.showAddressQRcodeCallback,
            onSigningCallback: widget.onSigningCallback,
            inPool: widget.addressesInPool.contains(address.address),
            showMessageSigner: widget.showMessageSigner,
          ),
      ],
    );
  }
}

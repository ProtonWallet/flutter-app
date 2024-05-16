class TransactionDetailFromBlockChain {
  int feeInSATS;
  String txid;
  int blockHeight;
  int timestamp;
  List<Recipient> recipients = [];

  TransactionDetailFromBlockChain(
      {required this.txid,
      required this.feeInSATS,
      required this.blockHeight,
      required this.timestamp});

  void addRecipient(Recipient recipient) {
    recipients.add(recipient);
  }
}

class Recipient {
  String bitcoinAddress;
  int amountInSATS;

  Recipient({required this.bitcoinAddress, required this.amountInSATS});
}

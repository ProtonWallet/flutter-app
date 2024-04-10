class AddressModel {
  int? id; // Proton @ ContactList.ContactID
  String serverID;
  String email;
  String serverWalletID;
  String serverAccountID;

  AddressModel({
    required this.id,
    required this.serverID,
    required this.email,
    required this.serverWalletID,
    required this.serverAccountID,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverID': serverID,
      'email': email,
      'serverWalletID': serverWalletID,
      'serverAccountID': serverAccountID,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'],
      serverID: map['serverID'],
      email: map['email'],
      serverWalletID: map['serverWalletID'],
      serverAccountID: map['serverAccountID'],
    );
  }
}

class ContactsModel {
  int? id; // Proton @ ContactList.ContactID
  String serverContactID;
  String name;
  String email;
  String canonicalEmail;
  int isProton;

  ContactsModel({
    required this.id,
    required this.serverContactID,
    required this.name,
    required this.email,
    required this.canonicalEmail,
    required this.isProton,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverContactID': serverContactID,
      'name': name,
      'email': email,
      'canonicalEmail': canonicalEmail,
      'isProton': isProton,
    };
  }

  factory ContactsModel.fromMap(Map<String, dynamic> map) {
    return ContactsModel(
      id: map['id'],
      serverContactID: map['serverContactID'],
      name: map['name'],
      email: map['email'],
      canonicalEmail: map['canonicalEmail'],
      isProton: map['isProton'],
    );
  }
}

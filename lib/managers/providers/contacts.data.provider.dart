import 'dart:async';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/contacts.dao.impl.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/proton_contacts_client.dart';
import 'package:wallet/rust/proton_api/contacts.dart';

class ContactsData {
  final WalletModel wallet;
  final List<AccountModel> accounts;

  ContactsData({required this.wallet, required this.accounts});
}

class ContactsDataProvider extends DataProvider {
  /// api client
  final ContactsClient contactClient;

  /// db dao
  final ContactsDao contactsDao;

  /// user id
  final String userID;

  /// need to monitor the db changes apply to this cache
  List<ContactsModel>? contactsData;

  ContactsDataProvider(
    this.contactClient,
    this.contactsDao,
    this.userID,
  );

  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  Future<List<ContactsModel>?> _getFromDB() async {
    /// try to find it fro cache
    final contacts = (await contactsDao.findAll()).cast<ContactsModel>();

    /// if found cache.
    if (contacts.isNotEmpty) {
      // TODO(Note): Temp fix. the contactID should be unique
      final Map<String, ContactsModel> uniqueContacts = {};
      for (var contact in contacts) {
        if (uniqueContacts.containsKey(contact.serverContactID)) {
          if (uniqueContacts[contact.serverContactID]!.id! < contact.id!) {
            uniqueContacts[contact.serverContactID] = contact;
          }
        } else {
          uniqueContacts[contact.serverContactID] = contact;
        }
      }
      return uniqueContacts.values.toList();
    }
    return null;
  }

  Future<void> fetchFromServer() async {
    /// try to fetch from server:
    final apiContacts = await contactClient.getContacts();
    for (ApiContactEmails apiContactEmail in apiContacts) {
      /// update and insert contact
      await insertUpdate(apiContactEmail);
    }
    contactsData = await _getFromDB();
  }

  Future<void> reloadCache() async {
    contactsData = await _getFromDB();
  }

  Future<List<ContactsModel>?> getContacts() async {
    if (contactsData != null) {
      return contactsData;
    }

    contactsData = await _getFromDB();
    if (contactsData != null) {
      return contactsData;
    }

    await fetchFromServer();
    if (contactsData != null) {
      return contactsData;
    }

    return null;
  }

  Future<String?> getContactName(String email) async {
    final List<ContactsModel>? contactsDataList = await getContacts();
    if (contactsDataList != null) {
      for (ContactsModel contactsModel in contactsDataList) {
        if (contactsModel.email == email) {
          return contactsModel.name;
        }
      }
    }
    return null;
  }

  Future<void> insertUpdate(ApiContactEmails contactEmail) async {
    await contactsDao.insertOrUpdate(
      contactEmail.id,
      contactEmail.name,
      contactEmail.email,
      contactEmail.canonicalEmail,
      contactEmail.isProton,
    );
  }

  Future<void> delete(String contactID) async {
    contactsDao.deleteByServerID(contactID);
  }

  Future<void> preLoad() async {
    getContacts();
  }

  @override
  Future<void> clear() async {
    contactsData?.clear();
    dataUpdateController.close();
  }

  @override
  Future<void> reload() async {}
}

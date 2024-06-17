import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/utils/crud.dart';

class ContactsNotifier extends StateNotifier<List<Contact>> {
  ContactsNotifier() : super([]);

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String myPhoneNumber = prefs.getString('myPhoneNumber')!;
    final data = await readContactsFromDb();
    final contactsList = data
        .map(
          (row) => Contact(
            name: row['name'] as String,
            phoneNumber: row['phoneNumber'] as String,
            imagePath: row['imagePath'] as String?,
            isMyContact:
                row['phoneNumber'] as String == myPhoneNumber ? true : false,
          ),
        )
        .toList();
    state = contactsList;
  }

  Future<void> addContact(WidgetRef ref, Contact newContact) async {
    insertContactIntoDb(newContact: newContact);

    state = [...state, newContact];
    await ref
        .read(recentsProvider.notifier)
        .updateRecentContact(newContact.phoneNumber, newContact);
  }

  Future<void> updateContact(
      {required WidgetRef ref,
      required String oldContactPhoneNumber,
      required Contact newContact}) async {
    updateContactInDb(
        newContact: newContact, oldPhoneNumber: oldContactPhoneNumber);

    updateRecentsInDb(
        newPhoneNumber: newContact.phoneNumber,
        oldPhoneNumber: oldContactPhoneNumber);

    final List<Contact> newState = List.from(state)
      ..removeWhere((contact) => contact.phoneNumber == oldContactPhoneNumber);
    newState.add(newContact);
    state = newState;
    await ref
        .read(recentsProvider.notifier)
        .updateRecentContact(oldContactPhoneNumber, newContact);
  }

  void deleteContact(WidgetRef ref, String phoneNumber) async {
    deleteContactsFromDb(phoneNumber: phoneNumber);

    state = List.from(state)
      ..removeWhere(
        (contact) => contact.phoneNumber == phoneNumber,
      );

    ref.read(recentsProvider.notifier).removeNamesFromRecents(phoneNumber);
  }
}

final contactsProvider = StateNotifierProvider<ContactsNotifier, List<Contact>>(
  (ref) => ContactsNotifier(),
);

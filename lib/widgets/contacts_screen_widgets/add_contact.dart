import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';

//ignore: must_be_immutable
class AddContact extends ConsumerWidget {
  AddContact({super.key});

  final _formKey = GlobalKey<FormState>();
  String? _enteredName;
  String? _enteredPhoneNumber;

  void _addContact(context, WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = FirebaseFirestore.instance;
      final docRef = db
          .collection("users")
          .doc(_enteredPhoneNumber);
      final document = await docRef.get();

      if (document.exists == false) {
        showAdaptiveDialog(
          context: context,
          builder: (context) => const AlertDialog.adaptive(
            backgroundColor: Color.fromARGB(255, 255, 166, 160),
            // i am pretty much using this row to center the text
            content: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Number doesn\'t exist',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      }

      ref.read(contactsProvider.notifier).addContact(
            Contact(
              name: _enteredName!,
              phoneNumber: _enteredPhoneNumber!,
            ),
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog.adaptive(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Column(
        children: [
          const ContactAvatarCircle(avatarRadius: 20),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 350,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          value.trim().length > 50) {
                        return 'Name should be between 1 and 50 characters long.';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _enteredName = newValue;
                    },
                    maxLength: 50,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Name',
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null ||
                          value.trim().length != 11 ||
                          int.tryParse(value) == null) {
                        return 'Phone number is invalid';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _enteredPhoneNumber = changeLocalToIntl(localPhoneNumber: newValue!);
                    },
                    maxLength: 11,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Phone',
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () {
                  _addContact(context, ref);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.black),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

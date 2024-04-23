import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';

//ignore: must_be_immutable
class AddContact extends ConsumerStatefulWidget {
  const AddContact({super.key});

  @override
  ConsumerState<AddContact> createState() => _AddContactState();
}

class _AddContactState extends ConsumerState<AddContact> {
  final _formKey = GlobalKey<FormState>();
  String? _enteredName;
  String? _enteredPhoneNumber;
  bool _isAddingContact = false;

  void _addContact(context) async {
    setState(() {
      _isAddingContact = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final bool numberExists = await checkIfNumberExists(_enteredPhoneNumber!);
      if (numberExists == false) {
        showErrorDialog('Number doesn\'t exist', context);
        setState(() {
          _isAddingContact = false;
        });
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
    setState(() {
      _isAddingContact = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      _enteredPhoneNumber =
                          changeLocalToIntl(localPhoneNumber: newValue!);
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
                child: Text('Cancel',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
              TextButton(
                onPressed: _isAddingContact == true
                    ? null
                    : () {
                        _addContact(context);
                      },
                child: _isAddingContact == false
                    ? const Text('Save')
                    : const CircularProgressIndicator(),
              )
            ],
          )
        ],
      ),
    );
  }
}
>ppp
import 'package:flutter/material.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/widgets/contact_avatar_circle.dart';

//ignore: must_be_immutable
class AddContact extends StatelessWidget {
  AddContact({super.key});

  final _formKey = GlobalKey<FormState>();
  String? _enteredName;
  String? _enteredPhoneNumber;
  String? _enteredEmail;

  void _addContact(context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Navigator.of(context).pop(
        Contact(
            name: _enteredName!,
            phoneNumber: _enteredPhoneNumber!,
            email: _enteredEmail!),
      );
    }
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
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
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Name',
                        prefixIcon: Icon(
                          Icons.person,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null ||
                            value.trim().length != 11 ||
                            int.tryParse(value) == null) {
                          return 'Phone number is invalid';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredPhoneNumber = newValue;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Phone',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      validator: (value) {
                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        if (!emailRegex.hasMatch(value)) {
                          return "Invalid email.";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredEmail = newValue;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
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
                  _addContact(context);
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

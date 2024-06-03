import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class AddContactDialog extends ConsumerStatefulWidget {
  const AddContactDialog({
    super.key,
    this.phoneNumber,
    this.contact,
    this.name,
  });

  final String? phoneNumber;
  final Contact? contact;
  final String? name;

  @override
  ConsumerState<AddContactDialog> createState() => _AddContactState();
}

class _AddContactState extends ConsumerState<AddContactDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _enteredName;
  String? _enteredPhoneNumber;
  bool _isAddingContact = false;
  File? _imageFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _phoneNumberController.text = widget.contact!.localPhoneNumber;
      _imageFile = widget.contact!.imagePath == null
          ? null
          : File(widget.contact!.imagePath!);
    }

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveImage(File? imageFile) async {
    if (imageFile == null) {
      return;
    }
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(imageFile.path);
    await imageFile.copy('${appDir.path}/$filename');
  }

  void _addContact(context) async {
    setState(() {
      _isAddingContact = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _enteredPhoneNumber = widget.phoneNumber == null
          ? _enteredPhoneNumber
          : widget.phoneNumber!;

      final bool numberExists = await checkIfNumberExists(_enteredPhoneNumber!);

      final bool numberIsAlreadyAContact =
          checkIfContactIsAlreadyInContactList(_enteredPhoneNumber!, ref);
      if (numberExists == false ||
          numberIsAlreadyAContact == true && widget.contact == null) {
        String errorMessage = numberExists == false
            ? 'Number doesn\'t exist'
            : 'Number already exists';
        showADialog(
          header: 'Error!!',
          body: errorMessage,
          context: context,
          buttonText: 'ok',
          onPressed: () => Navigator.of(context).pop(),
        );
        setState(() {
          _isAddingContact = false;
        });
        return;
      }

      await _saveImage(_imageFile);

      if (widget.contact != null) {
        final newContact = Contact(
          name: _nameController.text,
          phoneNumber: changeLocalToIntl(_phoneNumberController.text),
          imagePath: _imageFile?.path,
          isMyContact: widget.contact!.isMyContact,
        );

        await ref.read(contactsProvider.notifier).updateContact(
              ref: ref,
              oldContactPhoneNumber: widget.contact!.phoneNumber,
              newContact: newContact,
            );
        Navigator.of(context).pop(newContact);
      } else {
        await ref.read(contactsProvider.notifier).addContact(
              Contact(
                name: _enteredName!.trim(),
                phoneNumber: _enteredPhoneNumber!,
                imagePath: _imageFile?.path,
              ),
            );
        Navigator.of(context).pop();
      }
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
          ContactAvatarCircle(
            onCirclePressed: () async {
              _imageFile = (await selectImage(context)) ?? _imageFile;
              setState(() {});
            },
            avatarRadius: 40,
            imagePath: _imageFile?.path,
          ),
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
                    controller: _nameController,
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
                  // if widget.phoneNumber is not null, then what we want to do is add a new contact and all we want
                  // from the user is the name since we already have the phoneNumber.
                  if (widget.phoneNumber == null)
                    TextFormField(
                      controller: _phoneNumberController,
                      validator: (value) {
                        if (value == null ||
                            value.trim().length != 11 ||
                            int.tryParse(value) == null) {
                          return 'Phone number is invalid';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredPhoneNumber = changeLocalToIntl(newValue!);
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
                    : () async {
                        // if (await checkForInternetConnection(context)) {
                        _addContact(context);
                        // }
                      },
                child: _isAddingContact == false
                    ? const Text('Save')
                    : const CircularProgressIndicator.adaptive(),
              )
            ],
          )
        ],
      ),
    );
  }
}

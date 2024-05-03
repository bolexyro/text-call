import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;

class AddContact extends ConsumerStatefulWidget {
  const AddContact({
    super.key,
    this.phoneNumber,
  });

  final String? phoneNumber;

  @override
  ConsumerState<AddContact> createState() => _AddContactState();
}

class _AddContactState extends ConsumerState<AddContact> {
  final _formKey = GlobalKey<FormState>();
  String? _enteredName;
  String? _enteredPhoneNumber;
  bool _isAddingContact = false;

  File? _imageFile;

  void _selectImage() async {
    print('tapped');
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      return;
    }

    setState(() {
      _imageFile = File(pickedImage.path);
    });
  }

  Future<void> saveImage(File? imageFile) async {
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
      if (numberExists == false) {
        showADialog(
          header: 'Error!!',
          body: 'Number doesn\'t exist',
          context: context,
          buttonText: 'ok',
          onPressed: () => Navigator.of(context).pop(),
        );
        setState(() {
          _isAddingContact = false;
        });
        return;
      }

      await saveImage(_imageFile);
      await ref.read(contactsProvider.notifier).addContact(
            Contact(
              name: _enteredName!.trim(),
              phoneNumber: _enteredPhoneNumber!,
              imagePath: _imageFile?.path,
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
          ContactAvatarCircle(
            onCirclePressed: _selectImage,
            avatarRadius: 40,
            purpose: Purpose.selectingImage,
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
                  if (widget.phoneNumber == null)
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

import 'package:another_flushbar/flushbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/utils.dart';
import 'package:http/http.dart' as http;

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final double _borderRadius = 5.0;
  String _selectedCategory = 'Report bug';
  bool _emailSending = false;
  bool _successFullySent = false;
  late final TextEditingController _descriptionTextEditingContoller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _descriptionTextEditingContoller = TextEditingController();
    super.initState();
  }

  void _sendEmail() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _emailSending = true;
    });

    final String emailSubject = _selectedCategory == 'Report bug'
        ? 'TEXTCALL BUG REPORT'
        : _selectedCategory == 'Request feature'
            ? 'TEXTCALL FEATURE REQUEST'
            : 'TEXTCALL FEEDBACK';
    final String emailBody = _descriptionTextEditingContoller.text;

    final url =
        Uri.https(backendRootUrl, 'submit-feedback/$emailSubject/$emailBody');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        _successFullySent = true;
        _emailSending = false;
      });
    } else {
      setState(() {
        _emailSending = false;
      });
      showFlushBar(
          Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.error,
          'Email not sent. Try again',
          FlushbarPosition.TOP,
          context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: makeColorLighter(Theme.of(context).colorScheme.surfaceContainer,
          isDarkMode ? 10 : -10),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: _successFullySent
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: _successFullySent
              ? [
                  const Icon(
                    Icons.check,
                    size: 30,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  const Text('Thank you for your feedback'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_borderRadius),
                        ),
                      ),
                      child: const Text('Close this window'),
                    ),
                  ),
                ]
              : [
                  Text(
                    'Report bug or request feature',
                    style: TextStyle(
                      fontSize: 25,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('I\'d like to '),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            onChanged: (_) {
                              setState(() {
                                _selectedCategory = _!;
                              });
                            },
                            value: _selectedCategory,
                            // hint: const Text('Report a bug'),
                            items: [
                              'Report bug',
                              'Request feature',
                              'Send Feedback'
                            ]
                                .map(
                                  (toElement) => DropdownMenuItem(
                                    value: toElement,
                                    child: Text(
                                      toElement,
                                    ),
                                  ),
                                )
                                .toList(),
                            buttonStyleData: ButtonStyleData(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(_borderRadius),
                                border: Border.all(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                                // color: Colors.white,
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(_borderRadius),
                                // color: Colors.redAccent,
                              ),
                              offset: const Offset(-20, 0),
                              scrollbarTheme: ScrollbarThemeData(
                                radius: const Radius.circular(40),
                                thickness: WidgetStateProperty.all(6),
                                thumbVisibility: WidgetStateProperty.all(true),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                              padding: EdgeInsets.only(left: 14, right: 14),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Description'),
                  const SizedBox(
                    height: 10,
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      minLines: 2,
                      maxLines: 20,
                      controller: _descriptionTextEditingContoller,
                      decoration: InputDecoration(
                        hintText: 'Enter a desceiption',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_borderRadius),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.split('').length < 5) {
                          return 'You need to submit at least 5 words';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _emailSending ? null : _sendEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? null : Colors.blueGrey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_borderRadius),
                        ),
                      ),
                      child: _emailSending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Submit'),
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}

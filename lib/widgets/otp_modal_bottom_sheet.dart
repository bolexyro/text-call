import 'package:flutter/material.dart';

class OTPModalBottomSheet extends StatefulWidget {
  const OTPModalBottomSheet({super.key});

  @override
  State<OTPModalBottomSheet> createState() => _OTPModalBottomSheetState();
}

class _OTPModalBottomSheetState extends State<OTPModalBottomSheet> {
  List<FocusNode> focusNodes = [];
  List<TextEditingController> textControllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      focusNodes.add(FocusNode());
      textControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    for (final controller in textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String getOTP() {
    String output = '';
    for (final controller in textControllers) {
      output += controller.text;
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.8,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 110,
              ),
              const Text(
                'Enter the Code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              const Text(
                'If the code has not been sent please just be patient and remain on this page. Thank you.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int index = 0; index < 6; index++)
                    SizedBox(
                      width: 50,
                      child: TextFormField(
                        autofocus: index == 0 ? true : false,
                        controller: textControllers[index],
                        focusNode: focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            FocusScope.of(context)
                                .nextFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            FocusScope.of(context)
                                .requestFocus(focusNodes[index - 1]);
                          }
                          if (value.length == 1 && index == 5) {
                            Navigator.of(context).pop(getOTP());
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        maxLength: 1,
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

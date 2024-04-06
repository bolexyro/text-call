import 'package:flutter/material.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CODE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 100),
            ),
            const Text(
              'VERIFICATION',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int index = 0; index < 6; index++)
                  SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: textControllers[index],
                      focusNode: focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(context)
                              .requestFocus(focusNodes[index + 1]);
                        }
                        if (value.isEmpty && index > 0) {
                          FocusScope.of(context)
                              .requestFocus(focusNodes[index - 1]);
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
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(getOTP());
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

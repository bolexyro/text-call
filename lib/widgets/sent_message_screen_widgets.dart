// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:text_call/models/complex_message.dart';

// import 'package:text_call/screens/sent_message_screens/sms_from_terminated.dart';
// import 'package:text_call/screens/sent_message_screens/sms_not_from_terminaed.dart';
// import 'package:text_call/models/regular_message.dart';

// // sms = sent message screen
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:text_call/models/regular_message.dart';

enum HowSmsIsOpened {
  fromTerminatedToGrantOrDeyRequestAccess,
  notFromTerminatedToGrantOrDeyRequestAccess,
  fromTerminatedForPickCall,
  notFromTerminatedForPickedCall,
  // the belows 🤣 is the same thing as not from terminated to show message normally. Check contacts_or_recents_screen
  fromTerminatedToShowMessageAfterAccessRequestGranted,
  notFromTerminatedToJustDisplayMessage,
}

// class SentMessageScreen extends StatelessWidget {
//   const SentMessageScreen({
//     super.key,
//     required this.regularMessage,
//     required this.complexMessage,
//     required this.howSmsIsOpened,
//   });

//   // this messages should not be null if howsmsisopened == notfromterminatedtoshow message
//   final RegularMessage? regularMessage;
//   final ComplexMessage? complexMessage;
//   final HowSmsIsOpened howSmsIsOpened;
//   @override
//   Widget build(BuildContext context) {
//     if (howSmsIsOpened == HowSmsIsOpened.fromTerminatedForPickCall ||
//         howSmsIsOpened ==
//             HowSmsIsOpened.fromTerminatedToGrantOrDeyRequestAccess ||
//         howSmsIsOpened ==
//             HowSmsIsOpened
//                 .fromTerminatedToShowMessageAfterAccessRequestGranted) {
//       return SmsFromTerminated(
//         howSmsIsOpened: howSmsIsOpened,
//       );
//     }
//     return SmsNotFromTerminated(
//       regularMessage: regularMessage,
//       complexMessage: complexMessage,
//       howSmsIsOpened: howSmsIsOpened,
//     );
//   }
// }

class MyAnimatedTextWidget extends StatelessWidget {
  const MyAnimatedTextWidget({
    super.key,
    required this.message,
  });

  final RegularMessage message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedTextKit(
        displayFullTextOnTap: true,
        animatedTexts: [
          TyperAnimatedText(
            message.messageString,
            textAlign: TextAlign.center,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40,
              color: message.backgroundColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
            ),
            speed: const Duration(milliseconds: 100),
          ),
        ],
        repeatForever: false,
        totalRepeatCount: 1,
      ),
    );
  }
}

class ScaffoldTitle extends StatelessWidget {
  const ScaffoldTitle({
    super.key,
    required this.color,
    required this.isOutgoing,
  });

  final Color color;
  final bool isOutgoing;

  @override
  Widget build(BuildContext context) {
    return Text(
      isOutgoing
          ? 'To your loved one or not hehe.'
          : 'From your loved one or not hehe.',
      style: TextStyle(
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
    );
  }
}

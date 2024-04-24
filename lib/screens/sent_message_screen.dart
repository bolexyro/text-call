import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/phone_page_screen.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/models/message.dart';
import 'package:text_call/models/contact.dart';
import 'package:http/http.dart' as http;

class SentMessageScreen extends ConsumerWidget {
  const SentMessageScreen({
    super.key,
    this.fromTerminated = false,
    this.message,
  });

  final bool fromTerminated;
  final Message? message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = SharedPreferences.getInstance();

    return SafeArea(
      child: message == null
          ? FutureBuilder(
              future: prefs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error ${snapshot.error}'),
                  );
                }
                final prefs = snapshot.data;
                prefs!.reload();

                final String? callMessage = prefs.getString('callMessage');
                final String? backgroundColor =
                    prefs.getString('backgroundColor');
                final String? callerName = prefs.getString('callerName');
                final String? callerPhoneNumber =
                    prefs.getString('callerPhoneNumber');

                if (fromTerminated) {
                  final url = Uri.https('text-call-backend.onrender.com',
                      'call/accepted/$callerPhoneNumber');
                  http.get(url);
                }

                final newRecent = Recent(
                  message: Message(
                    message: callMessage!,
                    backgroundColor:
                        deJsonifyColor(json.decode(backgroundColor!)),
                  ),
                  contact: Contact(
                      name: callerName!, phoneNumber: callerPhoneNumber!),
                  category: RecentCategory.incomingAccepted,
                );

                ref.read(recentsProvider.notifier).addRecent(newRecent);

                return Scaffold(
                  appBar: AppBar(
                    forceMaterialTransparency: true,
                    title: const Text('From your loved one or not hehe'),
                  ),
                  backgroundColor: deJsonifyColor(
                    json.decode(backgroundColor),
                  ),
                  body: TheColumnWidget(
                    message: callMessage,
                    fromTerminated: fromTerminated,
                  ),
                );
              },
            )
          : Scaffold(
              appBar: AppBar(),
              backgroundColor: message!.backgroundColor,
              body: TheColumnWidget(
                message: message!.message,
              ),
            ),
    );
  }
}

class TheColumnWidget extends StatelessWidget {
  const TheColumnWidget({
    super.key,
    required this.message,
    this.fromTerminated = false,
  });

  final String message;
  final bool fromTerminated;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  message,
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              displayFullTextOnTap: true,
              repeatForever: false,
              totalRepeatCount: 1,
            ),
          ),
        ),
        if (fromTerminated)
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const PhonePageScreen(),
            )),
            child: const Icon(Icons.home),
          ),
      ],
    );
  }
}

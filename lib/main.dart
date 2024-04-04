import 'package:flutter/material.dart';
import 'package:text_call/screens/contacts_screen.dart';
import 'package:text_call/screens/keypad_screen.dart';
import 'package:text_call/screens/recents_screen.dart';

void main() {
  runApp(
    const TextCall(),
  );
}

class TextCall extends StatefulWidget {
  const TextCall({super.key});

  @override
  State<TextCall> createState() => _TextCallState();
}

class _TextCallState extends State<TextCall> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentPageIndex,
          indicatorColor: Colors.green,
          onDestinationSelected: (int index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
          height: 60,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.drag_indicator_sharp),
              label: 'keypad',
            ),
            NavigationDestination(
              icon: Badge(
                label: Text('3'),
                child: Icon(
                  Icons.recent_actors,
                ),
              ),
              label: 'Recents',
            ),
            NavigationDestination(
              icon: Icon(Icons.contacts),
              label: 'Contacts',
            ),
          ],
        ),
        body: [
          const KeypadScreen(),
          const RecentsScreen(),
          const ContactsScreen(),
        ][_currentPageIndex],
      ),
    );
  }
}

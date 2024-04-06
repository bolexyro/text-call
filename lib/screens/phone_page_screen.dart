import 'package:flutter/material.dart';
import 'package:text_call/widgets/phone_page_widgets/contacts_screen.dart';
import 'package:text_call/widgets/phone_page_widgets/keypad_screen.dart';
import 'package:text_call/widgets/phone_page_widgets/recents_screen.dart';

class PhonePageScreen extends StatefulWidget {
  const PhonePageScreen({super.key});

  @override
  State<PhonePageScreen> createState() => _PhonePageScreenState();
}

class _PhonePageScreenState extends State<PhonePageScreen> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

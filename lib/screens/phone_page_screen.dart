import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/auth_screen.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';

import 'package:text_call/widgets/phone_page_widgets/contacts_or_recents_screen.dart';
import 'package:text_call/widgets/phone_page_widgets/keypad_screen.dart';

class PhonePageScreen extends ConsumerStatefulWidget {
  const PhonePageScreen({super.key});

  @override
  ConsumerState<PhonePageScreen> createState() => _PhonePageScreenState();
}

class _PhonePageScreenState extends ConsumerState<PhonePageScreen> {
  int _currentPageIndex = 0;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _isDarkMode = Get.isDarkMode;

  @override
  void initState() {
    ref.read(contactsProvider.notifier).loadContacts();
    ref.read(recentsProvider.notifier).loadRecents();
    super.initState();
  }

  void _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUserLoggedIn', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Column(
                  children: [
                    ContactAvatarCircle(avatarRadius: 45, imagePath: null),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Me @ 09027929326'),
                  ],
                ),
              ),
              SwitchListTile.adaptive(
                activeColor: const Color.fromARGB(255, 57, 69, 83),
                value: _isDarkMode,
                onChanged: (newValue) async {
                  setState(() {
                    _isDarkMode = newValue;
                  });
                  Get.changeThemeMode(
                      Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                  // for some reason when it is on dark mode, Get.isDarkMode would give false and true otherwise
                  Get.isDarkMode;
                  (await SharedPreferences.getInstance())
                      .setBool('isDarkMode', !Get.isDarkMode);
                },
                title: const Text('Dark Mode'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log Out'),
                onTap: () => _logout(),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: SizedBox(
          child: NavigationBar(
            selectedIndex: _currentPageIndex,
            indicatorColor: Colors.blue,
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
                icon: Icon(
                  Icons.recent_actors,
                ),
                label: 'Recents',
              ),
              NavigationDestination(
                icon: Icon(Icons.contacts),
                label: 'Contacts',
              ),
            ],
          ),
        ),
        body: [
          KeypadScreen(
            scaffoldKey: _key,
          ),
          const ContactsRecentsScreen(
            whichScreen: WhichScreen.recent,
          ),
          const ContactsRecentsScreen(
            whichScreen: WhichScreen.contact,
          ),
        ][_currentPageIndex],
      ),
    );
  }
}

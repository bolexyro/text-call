import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/auth_screen.dart';
import 'package:text_call/screens/settings_screen.dart';
import 'package:text_call/utils/utils.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isDarkMode = Get.isDarkMode;
  late Future<String> _futureToWaitFor;

  @override
  void initState() {
    _futureToWaitFor = _loadThingsNeeded();
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

  Future<String> _loadThingsNeeded() async {
    await ref.read(contactsProvider.notifier).loadContacts();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('myPhoneNumber')!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: Column(
            children: [
              SizedBox(
                height: 210,
                child: DrawerHeader(
                  padding: const EdgeInsets.only(top: 30),
                  child: FutureBuilder(
                    future: _futureToWaitFor,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                              'Please close and reopen the drawer. Sorry for the inconvenience'),
                        );
                      }
                      final String myPhoneNumber = snapshot.data!;
                      final myContact = ref
                          .watch(contactsProvider)
                          .where(
                              (contact) => contact.phoneNumber == myPhoneNumber)
                          .first;
                      return Column(
                        children: [
                          ContactAvatarCircle(
                            avatarRadius: 45,
                            imagePath: myContact.imagePath,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                              '${myContact.name} @${changeIntlToLocal(myContact.phoneNumber)}'),
                        ],
                      );
                    },
                  ),
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
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                title: const Text('Draft'),
                onTap: () {},
              ),
              const Spacer(),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/icons/logout.svg',
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).iconTheme.color!,
                    BlendMode.srcIn,
                  ),
                ),
                title: const Text('Log Out'),
                onTap: () => _logout(),
              ),
              const SizedBox(
                height: 30,
              )
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
            scaffoldKey: _scaffoldKey,
          ),
          ContactsRecentsScreen(
            scaffoldKey: _scaffoldKey,
            whichScreen: WhichScreen.recent,
          ),
          ContactsRecentsScreen(
            scaffoldKey: _scaffoldKey,
            whichScreen: WhichScreen.contact,
          ),
        ][_currentPageIndex],
      ),
    );
  }
}

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/screens/access_requests_screen.dart';
import 'package:text_call/screens/auth_screen.dart';
import 'package:text_call/screens/settings_screen.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  Future<String> _loadThingsNeeded() async {
    await ref.read(contactsProvider.notifier).loadContacts();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('myPhoneNumber')!;
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
    bool isDarkMode = Get.isDarkMode;

    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: DrawerHeader(
              padding: const EdgeInsets.only(top: 30),
              child: FutureBuilder(
                future: _loadThingsNeeded(),
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
                      .where((contact) => contact.phoneNumber == myPhoneNumber)
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
            value: isDarkMode,
            onChanged: (newValue) async {
              setState(() {
                isDarkMode = newValue;
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
            leading: SvgPicture.asset(
              'assets/icons/draft.svg',
              height: 24,
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
            title: const Text('Draft'),
            onTap: () => showFlushBar(
              const Color.fromARGB(255, 0, 63, 114),
              'Drafts are currently unavailable.',
              FlushbarPosition.TOP,
              context,
            ),
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/colorful-mail.svg',
              height: 24,
              // colorFilter: ColorFilter.mode(
              //   Theme.of(context).iconTheme.color!,
              //   BlendMode.srcIn,
              // ),
            ),
            title: const Text('Access Requests'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AccessRequestsScreen(),
              ),
            ),
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
    );
  }
}

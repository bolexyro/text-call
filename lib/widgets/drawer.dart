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
import 'package:text_call/widgets/feedback_dialog.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({
    super.key,
    required this.myPhoneNumber,
  });

  final String myPhoneNumber;

  void _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUserLoggedIn', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myContact = ref
        .watch(contactsProvider)
        .where((contact) => contact.phoneNumber == myPhoneNumber)
        .first;

    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: DrawerHeader(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
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
              ),
            ),
          ),
          const ThemeSwitchListTile(),
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
            ),
            title: const Text('Access Requests'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AccessRequestsScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Send Feedback'),
            onTap: () => showAdaptiveDialog(
                builder: (context) => const AlertDialog.adaptive(
                      contentPadding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      content: FeedbackDialog(),
                    ),
                context: context),
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
            onTap: () => _logout(context),
          ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}

class ThemeSwitchListTile extends StatefulWidget {
  const ThemeSwitchListTile({super.key});

  @override
  State<ThemeSwitchListTile> createState() => _ThemeSwitchListTileState();
}

class _ThemeSwitchListTileState extends State<ThemeSwitchListTile> {
  bool isDarkMode = Get.isDarkMode;
  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      activeColor: const Color.fromARGB(255, 57, 69, 83),
      value: isDarkMode,
      onChanged: (newValue) async {
        setState(() {
          isDarkMode = newValue;
        });
        Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
        // for some reason when it is on dark mode, Get.isDarkMode would give false and true otherwise
        (await SharedPreferences.getInstance())
            .setBool('isDarkMode', !Get.isDarkMode);
      },
      title: const Text('Dark Mode'),
    );
  }
}

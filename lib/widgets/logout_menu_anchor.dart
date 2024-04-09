import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/screens/auth_screen.dart';

class LogOutMenuAnchor extends StatelessWidget {
  const LogOutMenuAnchor({super.key});

  void _logout(context) async {
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
    return MenuAnchor(
      builder: (context, controller, child) {
        return Padding(
          padding: const EdgeInsets.only(right:10.0),
          child: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
          ),
        );
      },
      menuChildren: [
        MenuItemButton(
          child: const Text('Logout'),
          onPressed: () => _logout(context),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:text_call/screens/auth_screen.dart';

class KeypadScreenMenuAnchor extends StatelessWidget {
  const KeypadScreenMenuAnchor({super.key});

  void _logout(context) {
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
        return IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      menuChildren: [
        const MenuItemButton(
          child: Text('Speed dial numbers'),
        ),
        const MenuItemButton(
          child: Text('Open to last viewed'),
        ),
        const MenuItemButton(
          child: Badge(
            child: Text('Speed dial numbers'),
          ),
        ),
        MenuItemButton(
          child: const Text('Logout'),
          onPressed: () => _logout(context),
        ),
      ],
    );
  }
}

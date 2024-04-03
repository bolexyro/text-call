import 'package:flutter/material.dart';

class KeypadScreenMenuAnchor extends StatelessWidget {
  const KeypadScreenMenuAnchor({super.key});

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
      menuChildren: const [
        MenuItemButton(
          child: Text('Speed dial numbers'),
        ),
        MenuItemButton(
          child: Text('Open to last viewed'),
        ),
        MenuItemButton(
          child: Badge(
            child: Text('Speed dial numbers'),
          ),
        ),
      ],
    );
  }
}

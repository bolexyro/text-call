import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/widgets/drawer.dart';
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

  @override
  void initState() {
    ref.read(recentsProvider.notifier).loadRecents();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
    drawer: const AppDrawer(),
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
      body: SafeArea(
          child: [
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
      ][_currentPageIndex]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/providers/contacts_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_avatar_circle.dart';
import 'package:text_call/widgets/expandable_list_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  bool isDark = false;

  String currentSeachText = '';
  bool resultsBarIsShown = false;

  final List<bool> _expandedBoolsList = [];

  void _changeTileExpandedStatus(int index) {
    setState(() {
      _expandedBoolsList[index] = !_expandedBoolsList[index];
      for (int i = 0; i < _expandedBoolsList.length; i++) {
        if (i != index && _expandedBoolsList[i] == true) {
          _expandedBoolsList[i] = false;
        }
      }
    });
  }

  List<Contact> contacts = [];
  void updateContacts() {
    setState(
      () {
        contacts = ref
            .read(contactsProvider)
            .where(
              (eachContact) =>
                  eachContact.name.toLowerCase().contains(currentSeachText),
            )
            .toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.viewInsetsOf(context).vertical);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  onTap: () {
                    setState(() {
                      resultsBarIsShown = true;
                    });
                    // controller.openView();
                  },
                  onChanged: (_) {
                    currentSeachText = _.toLowerCase();
                    if (currentSeachText == '') {
                      setState(() {
                        contacts = [];
                      });
                      return;
                    }
                    updateContacts();
                    // controller.openView();
                  },
                  leading: const Icon(Icons.search),
                  trailing: <Widget>[
                    Tooltip(
                      message: 'Cancel',
                      child: IconButton(
                        isSelected: isDark,
                        onPressed: () {
                          controller.text = '';
                        },
                        icon: const Icon(Icons.close),
                      ),
                    )
                  ],
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                return List<ListTile>.generate(5, (int index) {
                  final String item = 'item $index';
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      setState(() {
                        controller.closeView(item);
                      });
                    },
                  );
                });
              },
            ),
          ),
          if (resultsBarIsShown)
            Expanded(
              child: Padding(
                  padding: EdgeInsets.only(
                    top: 12,
                    right: 12,
                    left: 12,
                    bottom: MediaQuery.viewInsetsOf(context).vertical == 0
                        ? 300
                        : MediaQuery.viewInsetsOf(context).vertical + 12,
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? makeColorLighter(Theme.of(context).primaryColor, 15)
                          : Colors.grey[200],
                    ),
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contactN = contacts[index];
                        final specialChStartIndex = contactN.name
                            .toLowerCase()
                            .indexOf(currentSeachText);

                        final specialChEndIndex =
                            specialChStartIndex + currentSeachText.length;
                        _expandedBoolsList.add(false);
                        return ExpandableListTile(
                          isExpanded: _expandedBoolsList[index],
                          // title: Text(contactN.name),
                          title: RichText(
                            text: TextSpan(
                              text: contactN.name
                                  .substring(0, specialChStartIndex),
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(
                                  text: contactN.name.substring(
                                      specialChStartIndex, specialChEndIndex),
                                  style: const TextStyle(color: Colors.blue),
                                ),
                                TextSpan(
                                  text: contactN.name
                                      .substring(specialChEndIndex),
                                ),
                              ],
                            ),
                          ),
                          leading: contactN.imagePath != null
                              ? ContactAvatarCircle(
                                  avatarRadius: 20,
                                  imagePath: contactN.imagePath,
                                )
                              : CircleAvatar(
                                  radius: 20,
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.deepPurple,
                                          Colors.blue,
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      contactN.name[0],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 25),
                                    ),
                                  ),
                                ),
                          tileOnTapped: () {
                            _changeTileExpandedStatus(index);
                          },
                          expandedContent: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Mobile ${contactN.localPhoneNumber}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showMessageWriterModalSheet(
                                        calleeName: contactN.name,
                                        calleePhoneNumber: contactN.phoneNumber,
                                        context: context,
                                      );
                                    },
                                    icon: SvgPicture.asset(
                                      'assets/icons/message-ring.svg',
                                      height: 24,
                                      colorFilter: ColorFilter.mode(
                                        Theme.of(context).iconTheme.color!,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // widget.onContactSelected(contactN);
                                    },
                                    icon: Icon(
                                      Icons.info_outlined,
                                      color: Theme.of(context).iconTheme.color!,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:text_call/models/contact.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/widgets/contacts_screen_widgets/contact_card_w_profile_pic_stack.dart';

class ContactDetailsWHistoryScreen extends ConsumerWidget {
  const ContactDetailsWHistoryScreen({
    super.key,
    required this.contact,
  });

  final Contact contact;

  String _groupHeaderText(DateTime headerDateTime) {
    if (DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day) ==
        DateTime(
            headerDateTime.year, headerDateTime.month, headerDateTime.day)) {
      return "Today";
    } else if (DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day - 1) ==
        DateTime(
            headerDateTime.year, headerDateTime.month, headerDateTime.day)) {
      return 'Yesterday';
    }
    return DateFormat('d MMMM').format(headerDateTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactHistory = ref
        .read(recentsProvider.notifier)
        .getRecentForAContact(contact.phoneNumber);

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ContactCardWProfilePicStack(contact: contact,)
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      FutureBuilder(
                        future: contactHistory,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                'There was an error fetching the data, Please go back to the previous page and come back.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          final recentsList = snapshot.data!;
                          if (recentsList.isEmpty) {
                            return Text(
                              'Start conversing with ${contact.name} to see your history.',
                              textAlign: TextAlign.center,
                            );
                          }
                          return GroupedListView(
                            shrinkWrap: true,
                            useStickyGroupSeparators: true,
                            // floatingHeader: true,
                            stickyHeaderBackgroundColor:
                                const Color.fromARGB(255, 240, 248, 255),
                            elements: recentsList,
                            groupBy: (recentN) => DateTime(
                                recentN.callTime.year,
                                recentN.callTime.month,
                                recentN.callTime.day),
                            groupSeparatorBuilder:
                                (DateTime groupHeaderDateTime) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _groupHeaderText(groupHeaderDateTime),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            order: GroupedListOrder.DESC,
                            itemBuilder: (context, recentN) {
                              return Column(
                                children: [
                                  ListTile(
                                    onTap: () {},
                                    leading:
                                        recentCategoryIconMap[recentN.category],
                                    title: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(DateFormat.Hm()
                                            .format(recentN.callTime)),
                                        Text(recentN.category.name),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    indent: 45,
                                    endIndent: 15,
                                  )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

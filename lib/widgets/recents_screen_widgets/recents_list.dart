import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/recent_details_screen.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/expandable_list_tile.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';

class RecentsList extends ConsumerStatefulWidget {
  const RecentsList({super.key});

  @override
  ConsumerState<RecentsList> createState() => _RecentsListState();
}

class _RecentsListState extends ConsumerState<RecentsList> {
  final List<bool> _listExpandedBools = [];
  // final recentsList = [
  //   Recent(
  //     name: 'Bolexyro',
  //     phoneNumber: '09027929326',
  //     category: RecentCategory.incomingAccepted,
  //   ),
  //   Recent(
  //     name: 'Bolexyronn',
  //     phoneNumber: '09027929326',
  //     category: RecentCategory.incomingRejected,
  //     callTime: DateTime(2024, 4, 13, 2),
  //   ),
  //   Recent(
  //     name: 'Bolexyrorrr',
  //     phoneNumber: '09027929326',
  //     category: RecentCategory.outgoingMissed,
  //     callTime: DateTime(2000, 0, 0, 0, 9),
  //   ),
  //   Recent(
  //     name: 'Giannis',
  //     phoneNumber: 'phoneNumber',
  //     category: RecentCategory.incomingAccepted,
  //     callTime: DateTime(2024, 4, 12),
  //   ),
  // ];

  void _changeTileExpandedStatus(index) {
    setState(() {
      _listExpandedBools[index] = !_listExpandedBools[index];
      for (int i = 0; i < _listExpandedBools.length; i++) {
        if (i != index && _listExpandedBools[i] == true) {
          _listExpandedBools[i] = false;
        }
      }
    });
  }

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
  Widget build(BuildContext context) {
    final recentsList = ref.watch(recentsProvider);

    // from the most recent date to the least recent. Descending order
    recentsList.sort(
      (a, b) => b.callTime.compareTo(a.callTime),
    );

    return Column(
      children: [
        const Text(
          'Phone',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        const SizedBox(
          height: 70,
        ),
        Row(
          children: [
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_alt),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            const SizedBox(width: 10),
          ],
        ),
        Expanded(
          child: GroupedListView(
            useStickyGroupSeparators: true,
            // floatingHeader: true,
            stickyHeaderBackgroundColor:
                const Color.fromARGB(255, 240, 248, 255),
            elements: recentsList,
            groupBy: (recentN) => DateTime(recentN.callTime.year,
                recentN.callTime.month, recentN.callTime.day),
            groupSeparatorBuilder: (DateTime groupHeaderDateTime) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _groupHeaderText(groupHeaderDateTime),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            order: GroupedListOrder.DESC,
            itemBuilder: (context, recentN) {
              int index = recentsList.indexOf(recentN);
              _listExpandedBools.add(false);
              return ExpandableListTile(
                tileOnTapped: () {
                  _changeTileExpandedStatus(index);
                },
                isExpanded: _listExpandedBools[index],
                leading: recentCategoryIconMap[recentsList[index].category]!,
                trailing: Text(
                  DateFormat.Hm().format(recentN.callTime),
                ),
                title: Text(recentsList[index].name),
                expandedContent: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Mobile ${recentN.phoneNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('Incoming Call'),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            showMessageWriterModalSheet(
                              calleeName: recentN.name,
                              calleePhoneNumber: recentN.phoneNumber,
                              context: context,
                            );
                          },
                          icon: const Icon(Icons.message),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RecentDetailsScreen(
                                  recent: recentN,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

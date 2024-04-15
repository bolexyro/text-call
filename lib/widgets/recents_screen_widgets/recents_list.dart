import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/screens/recent_details_screen.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/expandable_list_tile.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:text_call/widgets/filter_dialog.dart';

class RecentsList extends ConsumerStatefulWidget {
  const RecentsList({super.key});

  @override
  ConsumerState<RecentsList> createState() => _RecentsListState();
}

class _RecentsListState extends ConsumerState<RecentsList> {
  final List<bool> _listExpandedBools = [];
  CallFilters _selectedFilter = CallFilters.allCalls;
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

  void _showFilterDialog() async {
    final selectedFilter = await showAdaptiveDialog<CallFilters?>(
      context: context,
      builder: (context) => FilterDialog(currentFilter: _selectedFilter),
    );
    if (selectedFilter == null) {
      return;
    }
    setState(() {
      _selectedFilter = selectedFilter;
    });
  }

  List<Recent> _applyFilter(List<Recent> allRecents) {
    if (_selectedFilter == CallFilters.allCalls) {
      return allRecents;
    }

    if (_selectedFilter == CallFilters.incomingCalls) {
      return allRecents
          .where(
            (element) => [
              RecentCategory.incomingAccepted,
              RecentCategory.incomingMissed,
              RecentCategory.incomingRejected
            ].contains(element.category),
          )
          .toList();
    }

    if (_selectedFilter == CallFilters.outgoingCalls) {
      return allRecents
          .where(
            (element) => [
              RecentCategory.outgoingAccepted,
              RecentCategory.outgoingMissed,
              RecentCategory.outgoingRejected
            ].contains(element.category),
          )
          .toList();
    }

    if (_selectedFilter == CallFilters.missedCalls) {
      return allRecents
          .where(
            (element) => [
              RecentCategory.outgoingMissed,
              RecentCategory.incomingMissed
            ].contains(element.category),
          )
          .toList();
    }

    return allRecents
        .where(
          (element) => [
            RecentCategory.outgoingRejected,
            RecentCategory.incomingRejected
          ].contains(element.category),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final recentsList = _applyFilter(ref.watch(recentsProvider));

    for (int i = 0; i < recentsList.length; i++) {
      _listExpandedBools.add(false);
    }

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
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_alt),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            const SizedBox(width: 10),
          ],
        ),
        if (recentsList.isNotEmpty)
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
                  title: Text(recentsList[index].contact.name),
                  expandedContent: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Mobile ${recentN.contact.localPhoneNumber}',
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
                                calleeName: recentN.contact.name,
                                calleePhoneNumber: recentN.contact.phoneNumber,
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
        if (recentsList.isEmpty)
          const Center(
            child: Text('No Recents'),
          ),
      ],
    );
  }
}

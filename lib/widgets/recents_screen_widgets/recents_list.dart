import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/expandable_list_tile.dart';
import 'package:intl/intl.dart';

class RecentsList extends ConsumerStatefulWidget {
  const RecentsList({super.key});

  @override
  ConsumerState<RecentsList> createState() => _RecentsListState();
}

class _RecentsListState extends ConsumerState<RecentsList> {
  final List<bool> _listExpandedBools = [];

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

  @override
  Widget build(BuildContext context) {
    final recentsList = ref.watch(recentsProvider);
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
    //   ),
    //   Recent(
    //     name: 'Bolexyrorrr',
    //     phoneNumber: '09027929326',
    //     category: RecentCategory.outgoingMissed,
    //     callTime: DateTime(2000, 0, 0, 0, 9),
    //   ),
    // ];
    recentsList.sort(
      (a, b) => a.callTime.compareTo(b.callTime),
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
          child: ListView.builder(
            itemCount: recentsList.length,
            itemBuilder: (context, index) {
              _listExpandedBools.add(false);
              final recentN = recentsList[index];
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
                          onPressed: () {},
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

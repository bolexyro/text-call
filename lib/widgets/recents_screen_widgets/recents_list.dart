import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_call/models/recent.dart';
import 'package:text_call/providers/recents_provider.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/expandable_list_tile.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:text_call/widgets/dialogs/filter_dialog.dart';

class RecentsList extends ConsumerStatefulWidget {
  const RecentsList({
    super.key,
    required this.onRecentSelected,
    required this.screen,
    required this.scaffoldKey,
  });

  final void Function(Recent? selectedRecent) onRecentSelected;
  final Screen screen;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  ConsumerState<RecentsList> createState() => _RecentsListState();
}

class _RecentsListState extends ConsumerState<RecentsList> {
  final Map<Recent, bool> _expandedBoolsMap = {};
  CallFilters _selectedFilter = CallFilters.allCalls;
  double bigHeight = 185;
  double smallHeight = 70;
  late double animatedContainerHeight;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    animatedContainerHeight = bigHeight;
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _changeTileExpandedStatus(Recent recent) {
    setState(() {
      _expandedBoolsMap[recent] = !_expandedBoolsMap[recent]!;
      for (final loopRecent in _expandedBoolsMap.keys) {
        if (loopRecent != recent && _expandedBoolsMap[loopRecent] == true) {
          _expandedBoolsMap[loopRecent] = false;
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
              RecentCategory.incomingIgnored,
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
              RecentCategory.outgoingIgnored,
              RecentCategory.outgoingUnreachable,
              RecentCategory.outgoingRejected
            ].contains(element.category),
          )
          .toList();
    }
    if (_selectedFilter == CallFilters.ignoredCalls) {
      return allRecents
          .where(
            (element) => [
              RecentCategory.outgoingIgnored,
              RecentCategory.incomingIgnored,
            ].contains(element.category),
          )
          .toList();
    }

    if (_selectedFilter == CallFilters.acceptedCalls) {
      return allRecents
          .where(
            (element) => [
              RecentCategory.outgoingAccepted,
              RecentCategory.incomingAccepted
            ].contains(element.category),
          )
          .toList();
    }
    if (_selectedFilter == CallFilters.unreachableCalls) {
      return allRecents
          .where(
            (element) => [
              RecentCategory.outgoingUnreachable,
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

  Future<void> _refreshRecents() async {
    widget.onRecentSelected(null);
    await ref.read(recentsProvider.notifier).loadRecents();
  }

  @override
  Widget build(BuildContext context) {
    final recentsList = _applyFilter(ref.watch(recentsProvider));


    return CustomScrollView(
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: true,
          delegate: MySliverAppBar(expandedHeight: 200.0),
        ),
        LiquidPullToRefresh(
          onRefresh: _refreshRecents,
          child: SliverGroupedListView(
            elements: recentsList,
            groupBy: (recentN) => DateTime(recentN.callTime.year,
                recentN.callTime.month, recentN.callTime.day),
            groupSeparatorBuilder: (DateTime groupHeaderDateTime) => Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _groupHeaderText(groupHeaderDateTime),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            order: GroupedListOrder.DESC,
            itemComparator: (element1, element2) =>
                element1.callTime.compareTo(element2.callTime),
            itemBuilder: (context, recentN) {
              _expandedBoolsMap[recentN] = _expandedBoolsMap.containsKey(recentN)
                  ? _expandedBoolsMap[recentN]!
                  : false;
          
              return Slidable(
                startActionPane: ActionPane(
                  motion: const BehindMotion(),
                  children: [
                    CustomSlidableAction(
                      onPressed: (context) {
                        showMessageWriterModalSheet(
                          context: context,
                          calleePhoneNumber: recentN.contact.phoneNumber,
                          calleeName: recentN.contact.name,
                          complexMessage: recentN.complexMessage,
                          regularMessage: recentN.regularMessage,
                        );
                      },
                      backgroundColor: const Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      child: SvgPicture.asset(
                        'assets/icons/message-ring.svg',
                        height: 30,
                        colorFilter:
                            const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
                endActionPane: recentN.recentIsAContact
                    ? null
                    : ActionPane(
                        motion: const BehindMotion(),
                        children: [
                          CustomSlidableAction(
                            onPressed: (context) {
                              showAddContactDialog(context,
                                  phoneNumber: recentN.contact.phoneNumber);
                            },
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.person_add),
                          ),
                        ],
                      ),
                child: widget.screen == Screen.phone
                    ? ExpandableListTile(
                        justARegularListTile: false,
                        tileOnTapped: () {
                          _changeTileExpandedStatus(recentN);
                        },
                        isExpanded: _expandedBoolsMap[recentN]!,
                        leading: recentCategoryIconMap[recentN.category]!,
                        trailing: Text(
                          DateFormat.Hm().format(recentN.callTime),
                        ),
                        title: Text(recentN.contact.name),
                        expandedContent: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            if (recentN.recentIsAContact)
                              Text(
                                'Mobile ${recentN.contact.localPhoneNumber}',
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            Text(recntCategoryStringMap[recentN.category]!),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (!recentN.recentIsAContact)
                                  IconButton(
                                    onPressed: () {
                                      showAddContactDialog(context,
                                          phoneNumber:
                                              recentN.contact.phoneNumber);
                                    },
                                    icon: const Icon(Icons.person_add),
                                  ),
                                IconButton(
                                  onPressed: () {
                                    showMessageWriterModalSheet(
                                      context: context,
                                      calleeName: recentN.contact.name,
                                      calleePhoneNumber:
                                          recentN.contact.phoneNumber,
                                      complexMessage: recentN.complexMessage,
                                      regularMessage: recentN.regularMessage,
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
                                    if (recentN.canBeViewed) {
                                      widget.onRecentSelected(recentN);
                                      return;
                                    }
                                    showADialog(
                                      header: 'Alert!!',
                                      body:
                                          "you have to ask ${recentN.contact.name} for permission to see this message since you rejected the call.",
                                      context: context,
                                      buttonText: 'Send  access request',
                                      onPressed: () {
                                        sendAccessRequest(recentN);
                                        Navigator.of(context).pop();
                                      },
                                    );
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
                      )
                    : Column(
                        children: [
                          ListTile(
                            leading: recentCategoryIconMap[recentN.category]!,
                            trailing: Text(
                              DateFormat.Hm().format(recentN.callTime),
                            ),
                            title: Text(recentN.contact.name),
                            onTap: () => widget.onRecentSelected(recentN),
                          ),
                          const Divider(
                            indent: 45,
                            endIndent: 15,
                          ),
                        ],
                      ),
              );
            },
          ),
        )
      ],
    );
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;

  MySliverAppBar({required this.expandedHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        Container(
          alignment: Alignment.bottomRight,
          color:Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_alt),
              ),
              IconButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('callMessage', 'callMessage');
                  await prefs.setString('callerPhoneNumber', '+2349027929326');
                  await prefs.setString('callerName', 'callerPhoneNumber');
                  await prefs.setString(
                    'backgroundColor',
                    json.encode(
                      {
                        'alpha': 200,
                        'red': 90,
                        'green': 90,
                        'blue': 20,
                      },
                    ),
                  );
                  createAwesomeNotification(
                    title: 'Bolexyro',
                    notificationPurpose: NotificationPurpose.forCall,
                  );
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Opacity(
            opacity: shrinkOffset / expandedHeight,
            child: Text(
              'Recents',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          // top: expandedHeight / 4 - shrinkOffset,
          // left: MediaQuery.of(context).size.width / 4,
          alignment: Alignment.center,
          child: Opacity(
            opacity: (1 - shrinkOffset / expandedHeight),
            child: Text(
              'Recents',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:text_call/providers/received_access_requests_provider.dart';
import 'package:text_call/utils/constants.dart';
import 'package:text_call/utils/utils.dart';
import 'package:text_call/widgets/access_requests_sceen_widgets/received_access_requests_tab.dart';
import 'package:text_call/widgets/access_requests_sceen_widgets/sent_access_requests_tab.dart';

class AccessRequestsScreen extends ConsumerStatefulWidget {
  const AccessRequestsScreen({super.key});

  @override
  ConsumerState<AccessRequestsScreen> createState() =>
      _AccessRequestsScreenState();
}

class _AccessRequestsScreenState extends ConsumerState<AccessRequestsScreen> {
  late final PageController _pageController;

  int _currentPage = 0;
  final bool _isRefreshing = false;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: CustomSlidingSegmentedControl(
                innerPadding: const EdgeInsets.all(10),
                fixedWidth: MediaQuery.sizeOf(context).width * .4,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color.fromARGB(255, 176, 208, 235)
                      : makeColorLighter(
                          Theme.of(context).colorScheme.surfaceContainer, 10),
                  borderRadius: BorderRadius.circular(30),
                ),
                thumbDecoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Theme.of(context).colorScheme.surfaceContainer
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                initialValue: _currentPage,
                children: {
                  0: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Received',
                        style: TextStyle(
                          color: _currentPage == 0
                              ? Colors.black
                              : Theme.of(context).iconTheme.color,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icons/receive-request.svg',
                        height: kIconHeight,
                        colorFilter: ColorFilter.mode(
                          _currentPage == 0
                              ? Colors.black
                              : Theme.of(context).iconTheme.color ??
                                  Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                  1: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sent',
                        style: TextStyle(
                          color: _currentPage == 1
                              ? Colors.black
                              : Theme.of(context).iconTheme.color,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icons/sent-request.svg',
                        height: kIconHeight,
                        colorFilter: ColorFilter.mode(
                          _currentPage == 1
                              ? Colors.black
                              : Theme.of(context).iconTheme.color ??
                                  Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  )
                },
                onValueChanged: (newValue) => setState(() {
                  _currentPage = newValue;
                  _pageController.animateToPage(
                    newValue,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.linear,
                  );
                }),
              ),
            ),
            Row(
              children: [
                const Spacer(),
                _isRefreshing
                    ? SizedBox(
                        height: Theme.of(context).iconTheme.size,
                        child: const CircularProgressIndicator(),
                      )
                    : IconButton(
                        onPressed: () => ref
                            .read(receivedAccessRequestsProvider.notifier)
                            .loadPendingReceivedAccessRequests(ref),
                        icon: const Icon(Icons.refresh),
                      ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                children: const [
                  AccessRequestsReceivedTab(),
                  AccessRequestsSentTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

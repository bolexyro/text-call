import 'package:flutter_riverpod/flutter_riverpod.dart';

const String contactsTableName = 'contacts';

class FloatingButtonsVisibleNotifier extends StateNotifier<bool> {
  FloatingButtonsVisibleNotifier() : super(true);

  void updateVisibility(bool visibilityStatus) async {
    state = visibilityStatus;
  }
}

final floatingButtonsVisibleProvider =
    StateNotifierProvider<FloatingButtonsVisibleNotifier, bool>(
  (ref) => FloatingButtonsVisibleNotifier(),
);

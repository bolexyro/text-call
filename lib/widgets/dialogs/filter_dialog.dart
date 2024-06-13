import 'package:flutter/material.dart';

enum CallFilters {
  allCalls,
  incomingCalls,
  outgoingCalls,
  ignoredCalls,
  rejectedCalls,
  acceptedCalls,
  unreachableCalls,
}

class FilterDialog extends StatefulWidget {
  const FilterDialog({
    super.key,
    required this.currentFilter,
  });

  final CallFilters currentFilter;
  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late CallFilters _selectedFilter;
  @override
  void initState() {
    _selectedFilter = widget.currentFilter;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 17.0, top: 8),
              child: Text(
                'Filter calls',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            RadioListTile(
              title: const Text('All calls'),
              value: CallFilters.allCalls,
              groupValue: _selectedFilter,
              onChanged: (CallFilters? value) {
                setState(() {
                  _selectedFilter = value!;
                  Navigator.of(context).pop(_selectedFilter);
                });
              },
            ),
            RadioListTile(
              title: const Text('Incoming calls'),
              value: CallFilters.incomingCalls,
              groupValue: _selectedFilter,
              onChanged: (CallFilters? value) {
                setState(() {
                  _selectedFilter = value!;
                  Navigator.of(context).pop(_selectedFilter);
                });
              },
            ),
            RadioListTile(
              title: const Text('Outgoing calls'),
              value: CallFilters.outgoingCalls,
              groupValue: _selectedFilter,
              onChanged: (CallFilters? value) {
                setState(() {
                  _selectedFilter = value!;
                  Navigator.of(context).pop(_selectedFilter);
                });
              },
            ),
            RadioListTile(
              title: const Text('Accepted calls'),
              value: CallFilters.acceptedCalls,
              groupValue: _selectedFilter,
              onChanged: (CallFilters? value) {
                setState(() {
                  _selectedFilter = value!;
                  Navigator.of(context).pop(_selectedFilter);
                });
              },
            ),
            RadioListTile(
              title: const Text('Rejected calls'),
              value: CallFilters.rejectedCalls,
              groupValue: _selectedFilter,
              onChanged: (CallFilters? value) {
                setState(() {
                  _selectedFilter = value!;
                  Navigator.of(context).pop(_selectedFilter);
                });
              },
            ),
            RadioListTile(
              title: const Text('Ignored calls'),
              value: CallFilters.ignoredCalls,
              groupValue: _selectedFilter,
              onChanged: (CallFilters? value) {
                setState(() {
                  _selectedFilter = value!;
                  Navigator.of(context).pop(_selectedFilter);
                });
              },
            ),
            RadioListTile(
              title: const Text('Unanswered calls'),
              value: CallFilters.unreachableCalls,
              groupValue: _selectedFilter,
              onChanged: (CallFilters? value) {
                setState(() {
                  _selectedFilter = value!;
                  Navigator.of(context).pop(_selectedFilter);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

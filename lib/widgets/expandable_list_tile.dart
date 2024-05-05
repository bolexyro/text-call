import 'package:flutter/material.dart';

class ExpandableListTile extends StatefulWidget {
  const ExpandableListTile({
    super.key,
    required this.leading,
    required this.title,
    required this.expandedContent,
    required this.isExpanded,
    required this.tileOnTapped,
    this.trailing,
    required this.justARegularListTile,
  });

  final Widget leading;
  final Widget title;
  final Widget? trailing;
  final Widget? expandedContent;
  final bool? isExpanded;
  final void Function() tileOnTapped;
  final bool justARegularListTile;

  @override
  State<ExpandableListTile> createState() => _ExpandableListTileState();
}

class _ExpandableListTileState extends State<ExpandableListTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: widget.tileOnTapped,
          leading: widget.leading,
          title: widget.title,
          trailing: widget.trailing,
        ),
        if (!widget.justARegularListTile && widget.isExpanded!) widget.expandedContent!,
        const Divider(
          indent: 45,
          endIndent: 15,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'list_item.dart';

class ListDetailLayout extends StatefulWidget {
  final List<ListItem> items;
  final Widget Function(BuildContext context, int index) detailBuilder;
  final Widget? emptyDetail;
  final int? initialSelectedIndex;

  const ListDetailLayout({
    super.key,
    required this.items,
    required this.detailBuilder,
    this.emptyDetail,
    this.initialSelectedIndex,
  });

  @override
  State<ListDetailLayout> createState() => _ListDetailLayoutState();
}

class _ListDetailLayoutState extends State<ListDetailLayout> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Theme(
      data: currentTheme.copyWith(
        listTileTheme: currentTheme.listTileTheme.copyWith(
          tileColor: currentTheme.colorScheme.surface,
          textColor: currentTheme.colorScheme.onSurface,
          selectedTileColor: currentTheme.colorScheme.secondary,
          selectedColor: currentTheme.colorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Flex(
          direction: Axis.horizontal,
          spacing: 8,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: ListView(
                children: widget.items
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: e.title,
                          subtitle: e.subtitle,
                          leading: e.leading,
                          selected: widget.items.indexOf(e) == _selectedIndex,
                          onTap: () {
                            setState(() {
                              _selectedIndex = widget.items.indexOf(e);
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(8.0),
                child: _selectedIndex != null
                    ? widget.detailBuilder(context, _selectedIndex!)
                    : (widget.emptyDetail ?? const SizedBox.expand()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

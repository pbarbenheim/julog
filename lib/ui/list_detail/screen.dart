import 'package:flutter/material.dart';

import 'list_item.dart';

class ListDetailLayout extends StatefulWidget {
  final List<ListItem> items;
  final Widget Function(BuildContext context, int index) detailBuilder;
  final Widget? form;
  final Widget? emptyDetail;
  final int? initialSelectedIndex;
  final bool showEmptyHint;

  const ListDetailLayout({
    super.key,
    required this.items,
    required this.detailBuilder,
    this.emptyDetail,
    this.initialSelectedIndex,
    this.form,
    this.showEmptyHint = true,
  });

  @override
  State<ListDetailLayout> createState() => _ListDetailLayoutState();
}

class _ListDetailLayoutState extends State<ListDetailLayout> {
  int? _selectedIndex;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  void didUpdateWidget(covariant ListDetailLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedIndex != oldWidget.initialSelectedIndex) {
      _selectedIndex = widget.initialSelectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    const emptyHint = Text(
      'Keine Einträge vorhanden. Füge einen neuen Eintrag hinzu.',
    );
    final Widget detail;
    if (_selectedIndex != null) {
      detail = widget.detailBuilder(context, _selectedIndex!);
    } else if (_showForm) {
      assert(widget.form != null);
      detail = widget.form!;
    } else if (widget.showEmptyHint && widget.items.isEmpty) {
      detail = const Center(child: emptyHint);
    } else {
      detail = widget.emptyDetail ?? const SizedBox.expand();
    }

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
              child: Stack(
                children: [
                  widget.items.isEmpty
                      ? SizedBox.expand(
                          child: Column(
                            children: [
                              const Padding(padding: EdgeInsets.all(16.0)),
                              widget.showEmptyHint
                                  ? emptyHint
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        )
                      : ListView(
                          children: widget.items
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    title: e.title,
                                    subtitle: e.subtitle,
                                    leading: e.leading,
                                    selected:
                                        widget.items.indexOf(e) ==
                                        _selectedIndex,
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = widget.items.indexOf(
                                          e,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                  if (widget.form != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = null;
                            _showForm = true;
                          });
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                ],
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
                child: detail,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:julog/repository/repository.dart';
import 'package:julog/ui/widgets/select_file.dart';
import 'package:julog/ui/widgets/util.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class Item extends StatelessWidget {
  final String title;
  late final String? Function(BuildContext context) getSubtitle;

  Item(
      {super.key,
      required this.title,
      String? subtitle,
      String? Function(BuildContext context)? getSubtitle}) {
    assert(subtitle == null || getSubtitle == null);

    if (getSubtitle != null) {
      this.getSubtitle = getSubtitle;
    } else {
      this.getSubtitle = (context) => subtitle;
    }
  }
}

class ItemList<T extends Item> extends StatelessWidget {
  final List<T> items;
  final ValueChanged<T> onChanged;
  final T? selected;
  final List<Widget>? chips;
  const ItemList({
    super.key,
    this.selected,
    required this.items,
    required this.onChanged,
    this.chips,
  });

  @override
  Widget build(BuildContext context) {
    final listview = ListView(
      children: items
          .map((item) => ListTile(
                title: Text(item.title),
                subtitle: Text(item.getSubtitle(context) ?? ""),
                onTap: () => onChanged(item),
                selected: item == selected,
              ))
          .toList(),
    );
    if (chips != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 5.0,
            children: chips!,
          ),
          Padding(padding: EdgeInsets.only(top: 5)),
          Expanded(child: listview),
        ],
      );
    } else {
      return listview;
    }
  }
}

class ItemDetail<T extends Item> extends StatelessWidget {
  final T? item;
  final List<Widget>? actions;
  const ItemDetail({super.key, this.item, this.actions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(item?.title ?? AppLocalizations.of(context)!.itemDetailDetail),
        actions: actions,
      ),
      body: Center(
        child: item ??
            Text(
              AppLocalizations.of(context)!.itemDetailEmptyHint,
            ),
      ),
    );
  }
}

class ListDetail<T extends Item> extends StatelessWidget {
  final T? selectedItem;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String listHeader;
  final Destination destination;
  final Widget? floatingActionButton;
  final List<Widget>? itemActions;
  final List<Widget>? filterChips;

  const ListDetail({
    super.key,
    this.selectedItem,
    required this.items,
    required this.onChanged,
    required this.listHeader,
    required this.destination,
    this.floatingActionButton,
    this.itemActions,
    this.filterChips,
  });

  Widget _buildMobileLayout() {
    if (selectedItem == null) {
      return JulogScaffold(
        appBar: AppBar(
          title: Text(listHeader),
        ),
        body: ItemList(
          items: items,
          onChanged: onChanged,
          selected: selectedItem,
          chips: filterChips,
        ),
        destination: destination,
        floatingActionButton: floatingActionButton,
      );
    }
    return ItemDetail(
      item: selectedItem,
      actions: itemActions,
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: JulogScaffold(
              body: ItemList(
                items: items,
                onChanged: onChanged,
                selected: selectedItem,
                chips: filterChips,
              ),
              destination: destination,
              floatingActionButton: floatingActionButton,
              appBar: AppBar(
                title: Text(listHeader),
              ),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: ItemDetail(
              item: selectedItem,
              actions: itemActions,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var dimension = MediaQuery.of(context).size.width;

    final useMobileLayout = dimension < 840;

    if (useMobileLayout) {
      return _buildMobileLayout();
    }
    return _buildTabletLayout();
  }
}

class JulogScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget body;
  final Destination destination;
  final Widget? floatingActionButton;
  const JulogScaffold({
    super.key,
    this.appBar,
    required this.body,
    required this.destination,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (appBar != null) {
      child = Scaffold(
        appBar: appBar,
        body: body,
      );
    } else {
      child = body;
    }
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
              destinations:
                  Destination.values.map((e) => e.railDestination).toList(),
              selectedIndex: destination.index,
              onDestinationSelected: (value) {
                final newDest = Destination.values[value];
                context.goNamed(newDest.routeName);
              },
              labelType: NavigationRailLabelType.all,
              trailing: JulogMoreMenu()),
          const VerticalDivider(),
          Expanded(child: child),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class JulogMoreMenu extends ConsumerStatefulWidget {
  const JulogMoreMenu({super.key});

  @override
  ConsumerState<JulogMoreMenu> createState() => _JulogMoreMenuState();
}

class _JulogMoreMenuState extends ConsumerState<JulogMoreMenu> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: "More Button");

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(repositoryProvider.notifier);
    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      menuChildren: [
        MenuItemButton(
          onPressed: JulogFileUIUtil.getCreateFileFn(context, notifier),
          leadingIcon: Icon(Icons.note_add_outlined),
          child: const Text("Neu"),
        ),
        MenuItemButton(
          onPressed: JulogFileUIUtil.getOpenFileFn(context, notifier),
          leadingIcon: Icon(Icons.file_open_outlined),
          child: const Text("Öffnen"),
        ),
        MenuItemButton(
          onPressed: () {
            showJulogAbout(context: context);
          },
          leadingIcon: Icon(Icons.info_outline_rounded),
          child: const Text("Über"),
        ),
      ],
      builder: (context, controller, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            focusNode: _buttonFocusNode,
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: Icon(Icons.more_horiz),
          ),
        );
      },
    );
  }
}

enum Destination {
  dashboard(
    NavigationRailDestination(
        icon: Icon(Icons.dashboard), label: Text("Dashboard")),
    "dashboard",
  ),
  julog(
    NavigationRailDestination(
      icon: Icon(Icons.book),
      label: Text("Dienstbuch"),
    ),
    "julog",
  ),
  jugendliche(
    NavigationRailDestination(
      icon: Icon(Icons.groups),
      label: Text("Jugendliche"),
    ),
    "jugendliche",
  ),
  identities(
    NavigationRailDestination(
      icon: Icon(Symbols.signature),
      label: Text("Identitäten"),
    ),
    "identities",
  ),
  betreuer(
    NavigationRailDestination(
      icon: Icon(Icons.group),
      label: Text("Betreuer"),
    ),
    "betreuer",
  ),
  kategorien(
    NavigationRailDestination(
      icon: Icon(Icons.label),
      label: Text("Kategorien"),
    ),
    "kategorien",
  );

  const Destination(this.railDestination, this.routeName);

  final NavigationRailDestination railDestination;
  final String routeName;
}

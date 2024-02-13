import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

abstract class Item extends StatelessWidget {
  final String title;
  final String? subtitle;

  const Item({super.key, required this.title, this.subtitle});
}

class ItemList<T extends Item> extends StatelessWidget {
  final List<T> items;
  final ValueChanged<T> onChanged;
  final T? selected;
  const ItemList({
    super.key,
    this.selected,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: items
          .map((item) => ListTile(
                title: Text(item.title),
                subtitle: Text(item.subtitle ?? ""),
                onTap: () => onChanged(item),
                selected: item == selected,
              ))
          .toList(),
    );
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
        title: Text(item?.title ?? "Details"),
        actions: actions,
      ),
      body: Center(
        child: item ??
            const Text(
              "Klicke ein Listenelement links an, um dir die Details anzusehen.",
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

  const ListDetail({
    super.key,
    this.selectedItem,
    required this.items,
    required this.onChanged,
    required this.listHeader,
    required this.destination,
    this.floatingActionButton,
    this.itemActions,
  });

  Widget _buildMobileLayout() {
    if (selectedItem == null) {
      return DienstbuchScaffold(
        appBar: AppBar(
          title: Text(listHeader),
        ),
        body: ItemList(
          items: items,
          onChanged: onChanged,
          selected: selectedItem,
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
            child: DienstbuchScaffold(
              body: ItemList(
                items: items,
                onChanged: onChanged,
                selected: selectedItem,
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

class DienstbuchScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget body;
  final Destination destination;
  final Widget? floatingActionButton;
  const DienstbuchScaffold({
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
          ),
          const VerticalDivider(),
          Expanded(child: child),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

enum Destination {
  dashboard(
    NavigationRailDestination(
        icon: Icon(Icons.dashboard), label: Text("Dashboard")),
    "dashboard",
  ),
  dienstbuch(
    NavigationRailDestination(
      icon: Icon(Icons.book),
      label: Text("Dienstbuch"),
    ),
    "dienstbuch",
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

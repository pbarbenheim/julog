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
  const ItemList({super.key, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: items
          .map((item) => ListTile(
                title: Text(item.title),
                subtitle: Text(item.subtitle ?? ""),
                onTap: () => onChanged(item),
              ))
          .toList(),
    );
  }
}

class ItemDetail<T extends Item> extends StatelessWidget {
  final T? item;
  const ItemDetail({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item?.title ?? "Details"),
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
  const ListDetail({
    super.key,
    this.selectedItem,
    required this.items,
    required this.onChanged,
    required this.listHeader,
    required this.destination,
    this.floatingActionButton,
  });

  Widget _buildMobileLayout() {
    if (selectedItem == null) {
      return DienstplanScaffold(
        appBar: AppBar(
          title: Text(listHeader),
        ),
        body: ItemList(
          items: items,
          onChanged: onChanged,
        ),
        destination: destination,
        floatingActionButton: floatingActionButton,
      );
    }
    return ItemDetail(
      item: selectedItem,
    );
  }

  Widget _buildTabletLayout() {
    return DienstplanScaffold(
      body: Row(
        children: [
          Flexible(
            flex: 1,
            child: ItemList(items: items, onChanged: onChanged),
          ),
          Flexible(
            flex: 3,
            child: ItemDetail(
              item: selectedItem,
            ),
          ),
        ],
      ),
      destination: destination,
      floatingActionButton: floatingActionButton,
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

class DienstplanScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget body;
  final Destination destination;
  final Widget? floatingActionButton;
  const DienstplanScaffold({
    super.key,
    this.appBar,
    required this.body,
    required this.destination,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
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
          ),
          const VerticalDivider(),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

enum Destination {
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
      label: Text("Signature"),
    ),
    "identities",
  ),
  betreuer(
    NavigationRailDestination(
      icon: Icon(Icons.group),
      label: Text("Betreuer"),
    ),
    "betreuer",
  );

  const Destination(this.railDestination, this.routeName);

  final NavigationRailDestination railDestination;
  final String routeName;
}

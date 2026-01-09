import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../router/router.dart';

enum Destination {
  dashboard(
    NavigationRailDestination(
      icon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    DashboardRoute(),
  ),
  julog(
    NavigationRailDestination(
      icon: Icon(Icons.book),
      label: Text('Dienstbuch'),
    ),
    PlaceholderRoute(),
  ),
  jugendliche(
    NavigationRailDestination(
      icon: Icon(Icons.groups),
      label: Text('Jugendliche'),
    ),
    PlaceholderRoute(),
  ),
  identities(
    NavigationRailDestination(
      icon: Icon(Symbols.signature),
      label: Text('Identitäten'),
    ),
    PlaceholderRoute(),
  ),
  betreuer(
    NavigationRailDestination(icon: Icon(Icons.group), label: Text('Betreuer')),
    PlaceholderRoute(),
  ),
  kategorien(
    NavigationRailDestination(
      icon: Icon(Icons.label),
      label: Text('Kategorien'),
    ),
    PlaceholderRoute(),
  );

  const Destination(this.railDestination, this.route);

  final NavigationRailDestination railDestination;
  final GoRouteData route;
}

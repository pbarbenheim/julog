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
  ),
  julog(
    NavigationRailDestination(
      icon: Icon(Icons.book),
      label: Text('Dienstbuch'),
    ),
  ),
  jugendliche(
    NavigationRailDestination(
      icon: Icon(Icons.groups),
      label: Text('Jugendliche'),
    ),
  ),
  identities(
    NavigationRailDestination(
      icon: Icon(Symbols.signature),
      label: Text('Identitäten'),
    ),
  ),
  betreuer(
    NavigationRailDestination(icon: Icon(Icons.group), label: Text('Betreuer')),
  ),
  kategorien(
    NavigationRailDestination(
      icon: Icon(Icons.label),
      label: Text('Kategorien'),
    ),
  );

  GoRouteData route() {
    return switch (this) {
      Destination.dashboard => const DashboardRoute(),
      Destination.julog => const PlaceholderRoute(),
      Destination.jugendliche => const PlaceholderRoute(),
      Destination.identities => const PlaceholderRoute(),
      Destination.betreuer => const PlaceholderRoute(),
      Destination.kategorien => const PlaceholderRoute(),
    };
  }

  const Destination(this.railDestination);

  final NavigationRailDestination railDestination;
}

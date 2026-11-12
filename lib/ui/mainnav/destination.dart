import 'package:material_ui/material_ui.dart';
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
  eintrag(
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
  ),
  jahresbericht(
    NavigationRailDestination(
      icon: Icon(Icons.summarize),
      label: Text('Jahresbericht'),
    ),
  );

  GoRouteData route() {
    return switch (this) {
      Destination.dashboard => const DashboardRoute(),
      Destination.eintrag => const EintragRoute(),
      Destination.jugendliche => const JugendlicheRoute(),
      Destination.identities => const IdentityRoute(),
      Destination.betreuer => const BetreuerRoute(),
      Destination.kategorien => const KategorieRoute(),
      Destination.jahresbericht => const JahresberichtRoute(),
    };
  }

  const Destination(this.railDestination);

  final NavigationRailDestination railDestination;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../repository/repository.dart';
import 'frame.dart';
import 'screens/betreuer.dart';
import 'screens/dashboard.dart';
import 'screens/dienstbuch.dart';
import 'screens/identities.dart';
import 'screens/jugendliche.dart';
import 'screens/kategorien.dart';
import 'screens/select_file.dart';

part 'routes.g.dart';

abstract class JulogBaseRoute extends GoRouteData {
  const JulogBaseRoute();
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage(child: build(context, state));
  }
}

@TypedGoRoute<KategorienRoute>(
  path: "/kategorien",
  name: "kategorien",
  routes: [
    TypedGoRoute<AddKategorienRoute>(path: "add"),
  ],
)
class KategorienRoute extends JulogBaseRoute with $KategorienRoute {
  final int? kategorieId;
  const KategorienRoute(this.kategorieId);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return KategorienScreen(id: kategorieId);
  }
}

class AddKategorienRoute extends JulogBaseRoute with $AddKategorienRoute {
  const AddKategorienRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AddKategorieScreen();
  }
}

@TypedGoRoute<JugendlicheRoute>(
    path: "/jugendliche",
    name: "jugendliche",
    routes: [
      TypedGoRoute<AddJugendlicheRoute>(path: "add"),
    ])
class JugendlicheRoute extends JulogBaseRoute with $JugendlicheRoute {
  final int? jugendlicherId;
  const JugendlicheRoute(this.jugendlicherId);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return JugendlicheScreen(id: jugendlicherId);
  }
}

class AddJugendlicheRoute extends JulogBaseRoute with $AddJugendlicheRoute {
  const AddJugendlicheRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AddJugendlicheScreen();
  }
}

@TypedGoRoute<BetreuerRoute>(
  path: "/betreuer",
  name: "betreuer",
  routes: [
    TypedGoRoute<AddBetreuerRoute>(path: "add"),
  ],
)
class BetreuerRoute extends JulogBaseRoute with $BetreuerRoute {
  final int? betreuerId;
  const BetreuerRoute(this.betreuerId);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BetreuerScreen(
      selectedId: betreuerId,
    );
  }
}

class AddBetreuerRoute extends JulogBaseRoute with $AddBetreuerRoute {
  const AddBetreuerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AddBetreuerScreen();
  }
}

@TypedGoRoute<DashboardRoute>(path: "/dashboard", name: "dashboard")
class DashboardRoute extends JulogBaseRoute with $DashboardRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashboardScreen();
  }
}

@TypedGoRoute<DienstbuchRoute>(
  path: '/julog',
  name: 'julog',
  routes: [
    TypedGoRoute<AddDienstbuchEintragRoute>(path: "add-eintrag"),
    TypedGoRoute<EintragRoute>(
      path: ":id",
      routes: [
        TypedGoRoute<SignEintragRoute>(path: "sign"),
      ],
    ),
  ],
)
class DienstbuchRoute extends JulogBaseRoute with $DienstbuchRoute {
  const DienstbuchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DienstbuchScreen();
  }
}

class EintragRoute extends JulogBaseRoute with $EintragRoute {
  final int id;

  EintragRoute(this.id);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return DienstbuchScreen(
      id: id,
    );
  }
}

class SignEintragRoute extends JulogBaseRoute with $SignEintragRoute {
  final int id;

  SignEintragRoute(this.id);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SignEintragScreen(id: id);
  }
}

class AddDienstbuchEintragRoute extends JulogBaseRoute
    with $AddDienstbuchEintragRoute {
  const AddDienstbuchEintragRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AddDienstbuchEintragScreen();
  }
}

@TypedGoRoute<IdentitiesRoute>(
  path: '/identities',
  name: "identities",
  routes: [
    TypedGoRoute<AddIdentityRoute>(path: "add"),
  ],
)
class IdentitiesRoute extends JulogBaseRoute with $IdentitiesRoute {
  final String? userId;
  const IdentitiesRoute(this.userId);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SignIdentitiesScreen(
      userId: userId,
    );
  }
}

class AddIdentityRoute extends JulogBaseRoute with $AddIdentityRoute {
  const AddIdentityRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AddIdentityScreen();
  }
}

@TypedGoRoute<SelectFileRoute>(path: "/select-file", name: "selectFile")
class SelectFileRoute extends JulogBaseRoute with $SelectFileRoute {
  const SelectFileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SelectFileScreen();
  }
}

class ErrorRoute extends GoRouteData {
  ErrorRoute({required this.error});
  final GoException error;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return JulogScaffold(
      body: Center(
        child: Column(
          children: [
            const Text(
                "Irgendetwas ist schiefgelaufen. Wir konnten die angeforderten Informationen nicht finden."),
            TextButton(
              onPressed: () => DashboardRoute().go(context),
              child: const Text("Zurück zum Dashboard"),
            ),
          ],
        ),
      ),
      destination: Destination.dashboard,
    );
  }
}

final routerProvider = Provider((ref) {
  return GoRouter(
    routes: $appRoutes,
    initialLocation: "/dashboard",
    redirect: (context, state) {
      final repo = ref.read(repositoryProvider);

      if (state.path == "/select-file") {
        if (repo != null) {
          return "/dashboard";
        }
        return null;
      }

      if (repo == null) {
        return "/select-file";
      }
      return null;
    },
    errorBuilder: (context, state) =>
        ErrorRoute(error: state.error!).build(context, state),
  );
});

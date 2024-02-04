// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $kategorienRoute,
      $jugendlicheRoute,
      $betreuerRoute,
      $dashboardRoute,
      $dienstbuchRoute,
      $identitiesRoute,
      $selectFileRoute,
    ];

RouteBase get $kategorienRoute => GoRouteData.$route(
      path: '/kategorien',
      name: 'kategorien',
      factory: $KategorienRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'add',
          factory: $AddKategorienRouteExtension._fromState,
        ),
      ],
    );

extension $KategorienRouteExtension on KategorienRoute {
  static KategorienRoute _fromState(GoRouterState state) => KategorienRoute(
        _$convertMapValue('kategorie-id', state.uri.queryParameters, int.parse),
      );

  String get location => GoRouteData.$location(
        '/kategorien',
        queryParams: {
          if (kategorieId != null) 'kategorie-id': kategorieId!.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AddKategorienRouteExtension on AddKategorienRoute {
  static AddKategorienRoute _fromState(GoRouterState state) =>
      const AddKategorienRoute();

  String get location => GoRouteData.$location(
        '/kategorien/add',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

RouteBase get $jugendlicheRoute => GoRouteData.$route(
      path: '/jugendliche',
      name: 'jugendliche',
      factory: $JugendlicheRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'add',
          factory: $AddJugendlicheRouteExtension._fromState,
        ),
      ],
    );

extension $JugendlicheRouteExtension on JugendlicheRoute {
  static JugendlicheRoute _fromState(GoRouterState state) => JugendlicheRoute(
        _$convertMapValue(
            'jugendlicher-id', state.uri.queryParameters, int.parse),
      );

  String get location => GoRouteData.$location(
        '/jugendliche',
        queryParams: {
          if (jugendlicherId != null)
            'jugendlicher-id': jugendlicherId!.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AddJugendlicheRouteExtension on AddJugendlicheRoute {
  static AddJugendlicheRoute _fromState(GoRouterState state) =>
      const AddJugendlicheRoute();

  String get location => GoRouteData.$location(
        '/jugendliche/add',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $betreuerRoute => GoRouteData.$route(
      path: '/betreuer',
      name: 'betreuer',
      factory: $BetreuerRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'add',
          factory: $AddBetreuerRouteExtension._fromState,
        ),
      ],
    );

extension $BetreuerRouteExtension on BetreuerRoute {
  static BetreuerRoute _fromState(GoRouterState state) => BetreuerRoute(
        _$convertMapValue('betreuer-id', state.uri.queryParameters, int.parse),
      );

  String get location => GoRouteData.$location(
        '/betreuer',
        queryParams: {
          if (betreuerId != null) 'betreuer-id': betreuerId!.toString(),
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AddBetreuerRouteExtension on AddBetreuerRoute {
  static AddBetreuerRoute _fromState(GoRouterState state) =>
      const AddBetreuerRoute();

  String get location => GoRouteData.$location(
        '/betreuer/add',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $dashboardRoute => GoRouteData.$route(
      path: '/dashboard',
      name: 'dashboard',
      factory: $DashboardRouteExtension._fromState,
    );

extension $DashboardRouteExtension on DashboardRoute {
  static DashboardRoute _fromState(GoRouterState state) => DashboardRoute();

  String get location => GoRouteData.$location(
        '/dashboard',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $dienstbuchRoute => GoRouteData.$route(
      path: '/dienstbuch',
      name: 'dienstbuch',
      factory: $DienstbuchRouteExtension._fromState,
    );

extension $DienstbuchRouteExtension on DienstbuchRoute {
  static DienstbuchRoute _fromState(GoRouterState state) =>
      const DienstbuchRoute();

  String get location => GoRouteData.$location(
        '/dienstbuch',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $identitiesRoute => GoRouteData.$route(
      path: '/identities',
      name: 'identities',
      factory: $IdentitiesRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'add',
          factory: $AddIdentityRouteExtension._fromState,
        ),
      ],
    );

extension $IdentitiesRouteExtension on IdentitiesRoute {
  static IdentitiesRoute _fromState(GoRouterState state) => IdentitiesRoute(
        state.uri.queryParameters['user-id'],
      );

  String get location => GoRouteData.$location(
        '/identities',
        queryParams: {
          if (userId != null) 'user-id': userId,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AddIdentityRouteExtension on AddIdentityRoute {
  static AddIdentityRoute _fromState(GoRouterState state) =>
      const AddIdentityRoute();

  String get location => GoRouteData.$location(
        '/identities/add',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $selectFileRoute => GoRouteData.$route(
      path: '/select-file',
      name: 'selectFile',
      factory: $SelectFileRouteExtension._fromState,
    );

extension $SelectFileRouteExtension on SelectFileRoute {
  static SelectFileRoute _fromState(GoRouterState state) =>
      const SelectFileRoute();

  String get location => GoRouteData.$location(
        '/select-file',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

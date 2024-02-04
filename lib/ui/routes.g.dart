// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $dashboardRoute,
      $dienstbuchRoute,
      $identitiesRoute,
      $selectFileRoute,
    ];

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
          name: 'add',
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

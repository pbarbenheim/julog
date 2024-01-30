// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $dienstbuchRoute,
      $identitiesRoute,
    ];

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

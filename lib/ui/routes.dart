import 'package:dienstbuch/ui/screens/identities.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

@TypedGoRoute<DienstbuchRoute>(path: '/dienstbuch', name: 'dienstbuch')
class DienstbuchRoute extends GoRouteData {
  const DienstbuchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // TODO: implement build
    return super.build(context, state);
  }
}

@TypedGoRoute<IdentitiesRoute>(path: '/identities', name: "identities")
class IdentitiesRoute extends GoRouteData {
  final String? userId;
  const IdentitiesRoute(this.userId);

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SignIdentitiesScreen(
      userId: userId,
    );
  }
}

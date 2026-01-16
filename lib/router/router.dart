import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../provider/jldb/jldb.dart';
import '../provider/jldb/julog_file.dart';
import '../ui/mainnav/destination.dart';
import '../ui/mainnav/file.dart';
import '../ui/mainnav/shell.dart';
import '../ui/placeholder_test.dart';

part 'router.g.dart';

abstract class JulogRouteData extends GoRouteData {
  const JulogRouteData();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    final child = build(context, state);
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }
}

@TypedShellRoute<MainShellRoute>(
  routes: [
    TypedGoRoute<DashboardRoute>(path: '/', name: 'dashboard'),
    TypedGoRoute<PlaceholderRoute>(path: '/julog', name: 'julog'),
  ],
)
class MainShellRoute extends ShellRouteData {
  const MainShellRoute();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    final destination = switch (state.topRoute?.name) {
      'dashboard' => Destination.dashboard,
      'julog' => Destination.julog,
      _ => throw StateError('Unknown route name: ${state.name}'),
    };
    return Shell(destination: destination, child: navigator);
  }
}

@immutable
class DashboardRoute extends JulogRouteData with $DashboardRoute {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const Center(child: Text('Dashboard'));
  }
}

//TODO needs removing
@immutable
class PlaceholderRoute extends JulogRouteData with $PlaceholderRoute {
  const PlaceholderRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PlaceholderTestWidget();
  }
}

@TypedGoRoute<FileSelectorRoute>(path: '/file-selector', name: 'fileSelector')
class FileSelectorRoute extends JulogRouteData with $FileSelectorRoute {
  final bool loading;
  const FileSelectorRoute({this.loading = false});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SelectFileScreen(loading: loading);
  }
}

@riverpod
GoRouter router(Ref ref) {
  final jldbStateNotifier = ValueNotifier<JulogFile?>(null);
  ref
    ..onDispose(() {
      jldbStateNotifier.dispose();
    })
    ..listen(julogServiceProvider, (previous, next) {
      jldbStateNotifier.value = next;
    });

  final router = GoRouter(
    initialLocation: const FileSelectorRoute().location,
    routes: $appRoutes,
    refreshListenable: jldbStateNotifier,
    redirect: (context, state) {
      final path = state.fullPath;
      if (path == null) {
        return null;
      }
      final isOnFileSelector =
          state.fullPath == const FileSelectorRoute().location;
      final currentFile = ref.read(julogServiceProvider);
      return currentFile.when(
        loaded: (value) {
          if (isOnFileSelector) {
            return const DashboardRoute().location;
          }
          return null;
        },
        loading: () {
          if (!isOnFileSelector) {
            return const FileSelectorRoute(loading: true).location;
          }
          return null;
        },
        closed: () {
          if (!isOnFileSelector) {
            return const FileSelectorRoute().location;
          }
          return null;
        },
        none: () {
          if (!isOnFileSelector) {
            return const FileSelectorRoute().location;
          }
          return null;
        },
      );
    },
  );

  ref.onDispose(() {
    router.dispose();
  });

  return router;
}

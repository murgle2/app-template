import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/resources/config.dart';
import 'package:frontend/src/pages/updatepage/update_page.dart';

extension RouteContext on BuildContext {
  RouteState get route => RouteState.instance;
}

class RouteState extends ChangeNotifier {
  String _path = ROUTE_HOME;

  String get path => _path;

  void setState(String newPath) {
    if (_path == newPath) return;
    _path = newPath;
    notifyListeners();
  }

  static final RouteState instance = RouteState();
}

class MyRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  final GlobalKey<NavigatorState> navigatorKey;
  final Map<String, dynamic> routes;

  final RouteState routeState = RouteState.instance;
  MyRouterDelegate({required this.routes})
      : navigatorKey = GlobalKey<NavigatorState>() {
    routeState.addListener(notifyListeners);
  }

  @override
  SynchronousFuture<void> setNewRoutePath(String path) {
    return SynchronousFuture(routeState.setState(path));
  }

  @override
  String get currentConfiguration => routeState.path;

  bool _matchesRoutePath(String key) {
    if (key == routeState.path) {
      return true;
    }
    return false;
  }

  List<Page> _getPage() {
    List<Page> pages = [];

    // TODO extract this
    var uri = Uri.parse(routeState.path);
    if (uri.hasQuery) {
      var resetToken = uri.queryParameters['resetToken'];
      var verifyToken = uri.queryParameters['verifyToken'];
      if (resetToken != null) {
        pages.add(MaterialPage(
          key: ValueKey(routeState.path),
          child: Builder(
            builder: ((context) =>
                UpdatePage(accountToken: resetToken, resetToken: true)),
          ),
        ));
        return pages;
      } else if (verifyToken != null) {
        pages.add(
          MaterialPage(
            key: ValueKey(routeState.path),
            child: Builder(
                builder: ((context) =>
                    UpdatePage(accountToken: verifyToken, resetToken: false))),
          ),
        );
        return pages;
      }
    }

    for (String key in routes.keys) {
      if (_matchesRoutePath(key) || key == '*') {
        pages.add(MaterialPage(
          key: ValueKey(routeState.path),
          child: Builder(
            builder: routes[key],
          ),
        ));
        break;
      }
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _getPage(),
      onPopPage: (route, result) => route.didPop(result),
    );
  }
}

class MyRouteInformationParser extends RouteInformationParser<String> {
  @override
  SynchronousFuture<String> parseRouteInformation(
      RouteInformation routeInformation) {
    return SynchronousFuture(routeInformation.location ?? ROUTE_HOME);
  }

  @override
  RouteInformation restoreRouteInformation(String data) {
    return RouteInformation(location: data);
  }
}

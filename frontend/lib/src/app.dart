import 'package:flutter/material.dart';
import 'package:frontend/resources/config.dart';
import 'package:frontend/resources/user_notifier.dart';
import 'package:frontend/resources/router.dart';

import 'package:frontend/src/pages/frontpage/front_page.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserNotifier>(
        create: (_) => UserNotifier(),
        child: MaterialApp.router(
          routerDelegate: MyRouterDelegate(
            routes: {
              ROUTE_HOME: (context) => FrontPage(),
              '*': (context) => FrontPage(),
            },
          ),
          routeInformationParser: MyRouteInformationParser(),
        ));
  }
}

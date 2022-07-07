import 'package:flutter/material.dart';
import 'package:frontend/resources/config.dart';
import 'package:frontend/resources/user_notifier.dart';
import 'package:frontend/resources/router.dart';
import 'package:provider/provider.dart';

class OtherAppBar extends StatelessWidget {
  const OtherAppBar({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
        builder: (context, userNotifier, _) => AppBar(
            elevation: 20,
            leadingWidth: kToolbarHeight + 160,
            leading: SizedBox(
              height: kToolbarHeight,
              width: kToolbarHeight + 50.0,
              child: TextButton(
                  child: Row(
                    children: [
                      Image.asset("assets/images/appbaricon.png",
                          width: 40, height: 40),
                      const SizedBox(width: 10),
                      const Text(
                        "Home",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ],
                  ),
                  onPressed: () => context.route.setState(ROUTE_HOME)),
            ),
            centerTitle: true,
            title: Text(title),
            backgroundColor: userNotifier.getColor(userNotifier.COLOR_APPBAR)));
  }
}

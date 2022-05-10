import 'package:flutter/material.dart';
import 'package:frontend/resources/user_notifier.dart';
import 'package:frontend/src/models/user_model.dart';
import 'package:frontend/src/services/user_service.dart';
import 'package:frontend/src/util/response_dialog.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CenterPage extends StatefulWidget {
  const CenterPage({Key? key}) : super(key: key);

  @override
  _CenterPage createState() => _CenterPage();
}

class _CenterPage extends State<CenterPage> {
  final keyToken = 'token';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late String? token;

  _prepareUser() async {
    SharedPreferences preferences = await _prefs;
    token = preferences.getString(keyToken);

    if (token == null) {
      Provider.of<UserNotifier>(context, listen: false).loadUser(null, context);
      return;
    }

    getCurrentUser(token!).then((User user) {
      Provider.of<UserNotifier>(context, listen: false).loadUser(user, context);
    }).catchError((error) {
      Provider.of<UserNotifier>(context, listen: false).loadUser(null, context);
      Provider.of<UserNotifier>(context, listen: false).logout();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const ResponseDialog(
            response: "Login expired",
            isError: true,
          );
        },
      );
    });
  }

  @override
  void initState() {
    _prepareUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
        builder: (context, userNotifier, _) => Container(
              color: userNotifier.getColor(userNotifier.COLOR_BACKGROUND),
              child: Stack(children: const [
                TabBarView(
                  children: [
                  ],
                ),
              ]),
            ));
  }
}

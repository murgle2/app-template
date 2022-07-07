import 'package:flutter/material.dart';
import 'package:frontend/resources/config.dart';
import 'package:frontend/src/pages/frontpage/center_page.dart';
import 'package:frontend/src/pages/frontpage/main_app_bar.dart';
import 'package:frontend/src/dialog/signup_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FrontPage extends StatefulWidget {
  FrontPage({Key? key}) : super(key: key);

  @override
  _FrontPage createState() => _FrontPage();
}

class _FrontPage extends State<FrontPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _prefs.then((SharedPreferences prefs) {
      if (prefs.getBool(keyAskToSignup) ?? true) {
        if (prefs.getString(keyToken) == null) {
          return Future.delayed(
              Duration.zero,
              () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    barrierDismissible: true,
                    opaque: false,
                    pageBuilder: (_, anim1, anim2) =>
                        FadeTransition(opacity: anim1, child: SignupDialog()),
                  )));
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: MainAppBar()),
      body: CenterPage(),
    );
  }
}

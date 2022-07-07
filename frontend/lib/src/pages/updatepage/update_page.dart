import 'package:flutter/material.dart';
import 'package:frontend/resources/user_notifier.dart';
import 'package:frontend/src/models/user_model.dart';
import 'package:frontend/src/services/user_service.dart';
import 'package:frontend/src/util/response_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/resources/router.dart';
import 'package:frontend/src/pages/updatepage/reset_password.dart';
import 'package:frontend/src/util/other_app_bar.dart';
import 'package:frontend/resources/config.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({Key? key, this.accountToken, this.resetToken})
      : super(key: key);

  final String? accountToken;
  final bool? resetToken;

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
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
    if (widget.accountToken != null && widget.resetToken != null) {
      if (widget.resetToken!) {
        Future.delayed(
            Duration.zero,
            () => Navigator.push(
                context,
                PageRouteBuilder(
                    barrierDismissible: true,
                    opaque: false,
                    pageBuilder: (_, anim1, anim2) => FadeTransition(
                          opacity: anim1,
                          child: ResetPassword(token: widget.accountToken),
                        ))));
      } else {
        verifyEmail(widget.accountToken!).then((String msg) {
          context.route.setState(ROUTE_HOME);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return ResponseDialog(
                  response: msg,
                  isError: false,
                );
              });
        }).catchError((error) {
          context.route.setState(ROUTE_HOME);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ResponseDialog(
                response: error.toString().substring(11),
                isError: true,
              );
            },
          );
        });
      }
    }

    return Consumer<UserNotifier>(
        builder: (context, userNotifier, _) => Scaffold(
            backgroundColor:
                userNotifier.getColor(userNotifier.COLOR_BACKGROUND),
            appBar: const PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: OtherAppBar(
                  title: "Update",
                ))));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/resources/config.dart';
import 'package:frontend/resources/user_notifier.dart';
import 'package:frontend/src/models/user_model.dart';
import 'package:frontend/resources/router.dart';
import 'package:frontend/src/services/user_service.dart';
import 'package:frontend/src/dialog/signup_dialog.dart';
import 'package:frontend/src/util/response_dialog.dart';
import 'package:provider/provider.dart';

class MainAppBar extends StatefulWidget {
  const MainAppBar({Key? key}) : super(key: key);

  @override
  _MainAppBarState createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  final String title = APP_NAME;

  void submitVerify(BuildContext context, User currentUser) {
    OverlayState overlayState = Overlay.of(context)!;
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Center(
        child: CircularProgressIndicator(color: COLOR_RED),
      );
    });
    overlayState.insert(overlayEntry);

    requestVerifyEmail(currentUser.email).then((String msg) {
      overlayEntry.remove();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ResponseDialog(
            response: msg,
            isError: false,
          );
        },
      );
    }).catchError((error) {
      overlayEntry.remove();
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

  void submitRecovery(BuildContext context, User currentUser) {
    OverlayState overlayState = Overlay.of(context)!;
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Center(
        child: CircularProgressIndicator(color: COLOR_RED),
      );
    });

    overlayState.insert(overlayEntry);

    requestResetPassword(currentUser.email).then((String msg) {
      overlayEntry.remove();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ResponseDialog(
            response: msg,
            isError: false,
          );
        },
      );
    }).catchError((error) {
      overlayEntry.remove();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
        builder: (context, userNotifier, _) => AppBar(
              elevation: 20,
              leadingWidth: kToolbarHeight + 100,
              leading: SizedBox(
                height: kToolbarHeight,
                width: kToolbarHeight + 50.0,
                child: TextButton(
                    child: Row(
                      children: const [
                        Text(
                          APP_NAME,
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ],
                    ),
                    onPressed: () => context.route.setState(ROUTE_HOME)),
              ),
              backgroundColor: userNotifier.getColor(userNotifier.COLOR_APPBAR),
              actions: <Widget>[
                if (!userNotifier.isLoggedIn)
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                          child: const Text("Log In or Sign Up",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(primary: COLOR_RED),
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                  barrierDismissible: true,
                                  opaque: false,
                                  pageBuilder: (_, anim1, anim2) =>
                                      FadeTransition(
                                          opacity: anim1,
                                          child: SignupDialog()),
                                ));
                          },
                        ),
                      ),
                    ],
                  ),
                Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: PopupMenuButton(
                        offset: const Offset(0, 48),
                        child: Icon(
                          CupertinoIcons.profile_circled,
                          color: userNotifier.isLoggedIn
                              ? COLOR_TEAL
                              : Colors.white,
                        ),
                        color: userNotifier.getColor(userNotifier.COLOR_PANEL),
                        onSelected: (int index) {
                          switch (index) {
                            case 1:
                              {
                                submitVerify(context, userNotifier.currentUser);
                              }
                              break;
                            case 2:
                              {
                                submitRecovery(
                                    context, userNotifier.currentUser);
                              }
                              break;
                            case 3:
                              {
                                userNotifier.logout();
                                Future.delayed(
                                    Duration.zero,
                                    () => Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          barrierDismissible: true,
                                          opaque: false,
                                          pageBuilder: (_, anim1, anim2) =>
                                              FadeTransition(
                                                  opacity: anim1,
                                                  child: SignupDialog()),
                                        )));
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) => <PopupMenuEntry<int>>[
                              if (userNotifier.isLoggedIn)
                                PopupMenuItem(
                                  enabled: false,
                                  child: Center(
                                    child: SelectableText(
                                      userNotifier.currentUser.email,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: userNotifier.getColor(
                                              userNotifier.COLOR_TEXT)),
                                    ),
                                  ),
                                ),
                              if (userNotifier.isLoggedIn ||
                                  (!userNotifier.isLoggedIn &&
                                      (MediaQuery.of(context).size.width <=
                                          700)))
                                PopupMenuItem(
                                    height: 6,
                                    child: SizedBox(
                                      child: Center(
                                        child: Container(
                                          margin:
                                              const EdgeInsetsDirectional.only(
                                                  start: 1.0, end: 1.0),
                                          height: 1.0,
                                          color: userNotifier.getColor(
                                              userNotifier.COLOR_TEXT),
                                        ),
                                      ),
                                    ),
                                    enabled: false),
                              PopupMenuItem(
                                enabled: false,
                                child: Row(
                                  children: [
                                    Text(
                                      "Dark Mode",
                                      style: TextStyle(
                                          color: userNotifier.getColor(
                                              userNotifier.COLOR_TEXT)),
                                    ),
                                    Switch(
                                        activeColor: COLOR_TEAL,
                                        value: userNotifier.isDarkMode,
                                        onChanged: (newValue) {
                                          setState(() {
                                            newValue
                                                ? userNotifier.setDarkMode()
                                                : userNotifier.setLightMode();
                                          });
                                          Navigator.of(context).pop();
                                        }),
                                  ],
                                ),
                              ),
                              if (userNotifier.isLoggedIn &&
                                  userNotifier.currentUser.role == Role.base)
                                PopupMenuItem(
                                  child: Text(
                                    "Verify Email",
                                    style: TextStyle(
                                        color: userNotifier
                                            .getColor(userNotifier.COLOR_TEXT)),
                                  ),
                                  value: 5,
                                ),
                              if (userNotifier.isLoggedIn)
                                PopupMenuItem(
                                  child: Text(
                                    "Reset Password",
                                    style: TextStyle(
                                        color: userNotifier
                                            .getColor(userNotifier.COLOR_TEXT)),
                                  ),
                                  value: 6,
                                ),
                              if (userNotifier.isLoggedIn)
                                PopupMenuItem(
                                  child: Text(
                                    "Log out",
                                    style: TextStyle(
                                        color: userNotifier
                                            .getColor(userNotifier.COLOR_TEXT)),
                                  ),
                                  value: 7,
                                ),
                            ])),
              ],
            ));
  }
}

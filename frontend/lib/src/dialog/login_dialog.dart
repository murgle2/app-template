import 'package:flutter/material.dart';
import 'package:frontend/resources/user_notifier.dart';
import 'package:frontend/src/models/token_model.dart';
import 'package:frontend/src/util/response_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/src/services/user_service.dart';
import 'package:frontend/resources/config.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({Key? key, this.email}) : super(key: key);

  final String? email;

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _formKeyLogin = GlobalKey<FormState>();
  late TextEditingController emailController;
  final passwordController = TextEditingController();
  bool _isObscure = true;
  bool _focusPassword = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLoading = false;

  @override
  void initState() {
    emailController = TextEditingController(text: widget.email);
    if (widget.email != null) {
      _focusPassword = true;
    }
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void setLoading(bool state) {
    setState(() {
      isLoading = state;
    });
  }

  void _login(UserNotifier userNotifier) async {
    if (_formKeyLogin.currentState!.validate()) {
      setLoading(true);
      final SharedPreferences prefs = await _prefs;
      OverlayState overlayState = Overlay.of(context)!;
      OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
        return Center(
          child: CircularProgressIndicator(color: COLOR_RED),
        );
      });
      overlayState.insert(overlayEntry);

      login(emailController.text, passwordController.text).then((Token token) {
        overlayEntry.remove();
        setLoading(false);
        prefs.setString(keyToken, token.accessToken);
        userNotifier.loginUser(token.accessToken);
        Navigator.of(context).popUntil((route) => route.isFirst);
      }).catchError((error) {
        overlayEntry.remove();
        setLoading(false);
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

  void submitRecovery(BuildContext context) {
    setLoading(true);
    OverlayState overlayState = Overlay.of(context)!;
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Center(
        child: CircularProgressIndicator(color: COLOR_RED),
      );
    });
    overlayState.insert(overlayEntry);

    if (emailController.text.isNotEmpty) {
      requestResetPassword(emailController.text).then((String msg) {
        overlayEntry.remove();
        setLoading(false);

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
        setLoading(false);

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
    } else {
      overlayEntry.remove();
      setLoading(false);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ResponseDialog(
            response: "Enter your email address",
            isError: true,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
        builder: (context, userNotifier, _) => Dialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                color: Colors.transparent,
                height: 270,
                width: 350,
                child: Column(
                  children: [
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    )),
                    Expanded(
                      child: Form(
                        key: _formKeyLogin,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 62,
                              child: TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  border: UnderlineInputBorder(),
                                  labelText: 'Email',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email address';
                                  }
                                  return null;
                                },
                                autofocus: !_focusPassword,
                              ),
                            ),
                            Container(
                              height: 62,
                              child: TextFormField(
                                obscureText: _isObscure,
                                controller: passwordController,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(0),
                                    border: UnderlineInputBorder(),
                                    labelText: 'Password',
                                    suffixIcon: IconButton(
                                        icon: Icon(_isObscure
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        onPressed: () {
                                          setState(() {
                                            _isObscure = !_isObscure;
                                          });
                                        })),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (value) =>
                                    isLoading ? null : _login(userNotifier),
                                autofocus: _focusPassword,
                              ),
                            ),
                            SizedBox.fromSize(size: Size(62, 62)),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    BackButton(
                                      color: Colors.black,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ElevatedButton(
                                      child: Text('Reset password'),
                                      style: ElevatedButton.styleFrom(
                                          primary: COLOR_RED),
                                      onPressed: () => isLoading
                                          ? null
                                          : submitRecovery(context),
                                    ),
                                    ElevatedButton(
                                      child: Text('Submit'),
                                      style: ElevatedButton.styleFrom(
                                          primary: COLOR_RED),
                                      onPressed: () => isLoading
                                          ? null
                                          : _login(userNotifier),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))));
  }
}

import 'package:flutter/material.dart';

import 'package:frontend/src/services/user_service.dart';
import 'package:frontend/resources/config.dart';
import 'package:frontend/src/util/response_dialog.dart';
import 'login_dialog.dart';
import '../models/user_model.dart';

class EmailSignupDialog extends StatefulWidget {
  const EmailSignupDialog({Key? key}) : super(key: key);

  @override
  _EmailSignupDialogState createState() => _EmailSignupDialogState();
}

class _EmailSignupDialogState extends State<EmailSignupDialog> {
  final _formKeySignUp = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isObscure = true;
  bool isLoading = false;

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

  void submitForm(BuildContext context) {
    if (_formKeySignUp.currentState!.validate()) {
      setLoading(true);
      OverlayState overlayState = Overlay.of(context)!;
      OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
        return Center(
          child: CircularProgressIndicator(color: COLOR_RED),
        );
      });
      overlayState.insert(overlayEntry);

      createAccount(emailController.text, passwordController.text)
          .then((User user) {
        overlayEntry.remove();
        setLoading(false);

        return Navigator.push(
            context,
            PageRouteBuilder(
              barrierDismissible: true,
              opaque: false,
              pageBuilder: (_, anim1, anim2) => FadeTransition(
                  opacity: anim1, child: LoginDialog(email: user.email)),
            ));
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                    "Email Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                )),
                Expanded(
                  child: Form(
                    key: _formKeySignUp,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 62,
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: UnderlineInputBorder(),
                              labelText: 'Email',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email address';
                              } else if (value.length > 80) {
                                return 'Email address must be shorter than 80 characters';
                              } else if (!RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value)) {
                                return 'Invalid email address';
                              }
                              return null;
                            },
                            autofocus: true,
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
                              labelText: 'Create password',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              } else if (value.length < 8) {
                                return 'Password must be at least 8 characters long';
                              } else if (value.length > 32) {
                                return 'Password cannot be longer than 32 characters';
                              } else if (!RegExp(
                                      '^[a-zA-Z0-9!@#\$&()\\-`.+,/"]*\$')
                                  .hasMatch(value)) {
                                return 'No spaces and only some special characters: !@#\$&()-‘./+,“';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          height: 62,
                          child: TextFormField(
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(0),
                                border: UnderlineInputBorder(),
                                labelText: 'Confirm password',
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
                              if (value != passwordController.text) {
                                return 'Passwords must match';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) =>
                                isLoading ? null : submitForm(context),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                BackButton(
                                  color: Colors.black,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                ElevatedButton(
                                  child: Text('Submit'),
                                  style: ElevatedButton.styleFrom(
                                      primary: COLOR_RED),
                                  onPressed: () =>
                                      isLoading ? null : submitForm(context),
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
            )));
  }
}

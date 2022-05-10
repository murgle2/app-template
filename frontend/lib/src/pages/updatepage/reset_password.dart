import 'package:flutter/material.dart';
import 'package:frontend/resources/config.dart';
import 'package:frontend/resources/router.dart';
import 'package:frontend/src/services/user_service.dart';
import 'package:frontend/src/util/response_dialog.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key, this.token}) : super(key: key);

  final String? token;

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _passwordKeyReset = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  bool isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void setLoading(bool state) {
    setState(() {
      isLoading = state;
    });
  }

  void submitForm(BuildContext context) {
    if (_passwordKeyReset.currentState!.validate()) {
      setLoading(true);
      OverlayState overlayState = Overlay.of(context)!;
      OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
        return Center(
          child: CircularProgressIndicator(color: COLOR_RED),
        );
      });
      overlayState.insert(overlayEntry);

      if (widget.token != null) {
        resetPassword(_passwordController.text, widget.token!)
            .then((String msg) {
          overlayEntry.remove();
          setLoading(false);
          context.route.setState(ROUTE_HOME);
        }).catchError((error) {
          overlayEntry.remove();
          setLoading(false);
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
      } else {
        overlayEntry.remove();
        setLoading(false);
        context.route.setState(ROUTE_HOME);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const ResponseDialog(
              response: "Generate a new password recovery link",
              isError: true,
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.transparent,
            height: 270,
            width: 350,
            child: Column(
              children: [
                const Center(
                    child: const Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: const Text(
                    "Reset Password",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                )),
                Expanded(
                  child: Form(
                    key: _passwordKeyReset,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 62,
                          child: TextFormField(
                            obscureText: _isObscure,
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: UnderlineInputBorder(),
                              labelText: 'Enter new password',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              } else if (value.length < 8) {
                                return 'Password needs to be at least 8 characters long';
                              } else if (value.length > 32) {
                                return 'Password cannot be longer than 32 characters';
                              } else if (!RegExp(
                                      '^[a-zA-Z0-9!@#\$&()\\-`.+,/"]*\$')
                                  .hasMatch(value)) {
                                return 'No spaces and only some special characters: !@#\$&()-‘./+,“';
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
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(0),
                                border: const UnderlineInputBorder(),
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
                              if (value != _passwordController.text) {
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
                                  child: const Text('Submit'),
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

import 'package:flutter/material.dart';
import 'package:frontend/src/models/token_model.dart';
import 'package:frontend/src/services/user_service.dart';
import 'package:frontend/src/pages/frontpage/front_page.dart';
import 'package:frontend/src/util/response_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/resources/config.dart';
import 'package:frontend/src/dialog/login_dialog.dart';

import 'email_signup_dialog.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignupDialog extends StatefulWidget {
  SignupDialog({Key? key}) : super(key: key);

  @override
  _SignupDialogState createState() => _SignupDialogState();
}

class _SignupDialogState extends State<SignupDialog> {
  final keyAskToSignup = 'ask_to_sign_up';
  late SharedPreferences prefs;
  final keyToken = 'token';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool isLoading = false;

  getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  void setLoading(bool state) {
    setState(() {
      isLoading = state;
    });
  }

  void _handleGoogleSignIn() async {
    setLoading(true);
    OverlayState overlayState = Overlay.of(context)!;
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Center(
        child: CircularProgressIndicator(color: COLOR_RED),
      );
    });
    overlayState.insert(overlayEntry);

    final SharedPreferences prefs = await _prefs;

    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: <String>['email'],
    );

    _googleSignIn.signIn().then((GoogleSignInAccount? account) {
      if (account != null) {
        account.authentication.then((GoogleSignInAuthentication auth) {
          googleLogin(auth.idToken!).then((Token token) {
            prefs.setString(keyToken, token.accessToken);
            overlayEntry.remove();
            setLoading(false);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return FrontPage();
            }));
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
        });
      } else {
        overlayEntry.remove();
        setLoading(false);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ResponseDialog(
              response: "Unable to connect to Google",
              isError: true,
            );
          },
        );
      }
    }).catchError((error) {
      overlayEntry.remove();
      setLoading(false);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ResponseDialog(
            response:
                "Sign in canceled.\n\nIf you are using an incognito browser tab then Google Sign In is not available.",
            isError: true,
          );
        },
      );
    });
  }

  void handleAppleSignIn() async {
    setLoading(true);
    OverlayState overlayState = Overlay.of(context)!;
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
      return Center(
        child: CircularProgressIndicator(color: COLOR_RED),
      );
    });
    overlayState.insert(overlayEntry);

    final SharedPreferences prefs = await _prefs;

    SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: 'live.xpo.service',
        redirectUri: Uri.parse("https://xpo.live"),
      ),
    ).then((AuthorizationCredentialAppleID credential) {
      if (credential.identityToken != null) {
        appleLogin(credential.identityToken!).then((Token token) {
          prefs.setString(keyToken, token.accessToken);
          overlayEntry.remove();
          setLoading(false);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return FrontPage();
          }));
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
              response: "Unable to connect to Apple",
              isError: true,
            );
          },
        );
      }
    }).catchError((error) {
      overlayEntry.remove();
      setLoading(false);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ResponseDialog(
            response: "Sign in canceled",
            isError: true,
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: COLOR_TRANSPARENT,
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.transparent,
        height: 225,
        width: 350,
        child: Column(
          children: [
            Center(
                child: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                "Continue with a free account!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            )),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/signup/google.png",
                                  width: 22, height: 22),
                              SizedBox(width: 10),
                              Text("Continue with Google",
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          onTap: () {
                            isLoading ? null : _handleGoogleSignIn();
                          }),
                      ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/signup/apple.png",
                                  width: 22, height: 22),
                              SizedBox(width: 10),
                              Text("Continue with Apple",
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          onTap: () {
                            isLoading ? null : handleAppleSignIn();
                          }),
                      ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/signup/email.png",
                                  width: 22, height: 22),
                              SizedBox(width: 10),
                              Text("Continue with Email",
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                  barrierDismissible: true,
                                  opaque: false,
                                  pageBuilder: (_, anim1, anim2) =>
                                      FadeTransition(
                                          opacity: anim1,
                                          child: EmailSignupDialog()),
                                ));
                          }),
                    ],
                  ),
                ),
                MediaQuery.of(context).size.width > 700
                    ? SizedBox(
                        height: 125,
                        child: Row(
                          children: [
                            VerticalDivider(
                              width: 2,
                              thickness: 2,
                              color: Colors.grey.shade600,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/placeholder.png",
                                    width: 100,
                                    height: 100,
                                  ),
                                  Text("Get the App")
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text("Don't show again",
                      style: TextStyle(color: COLOR_RED, fontSize: 12)),
                  onPressed: () {
                    prefs.setBool(keyAskToSignup, false);
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text("Later",
                      style: TextStyle(color: COLOR_RED, fontSize: 12)),
                  onPressed: () {
                    prefs.setBool(keyAskToSignup, true);
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  child: Text("Log In", style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(primary: COLOR_RED),
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          barrierDismissible: true,
                          opaque: false,
                          pageBuilder: (_, anim1, anim2) => FadeTransition(
                              opacity: anim1, child: LoginDialog()),
                        ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

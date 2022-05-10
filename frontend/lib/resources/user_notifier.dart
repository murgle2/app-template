import 'package:flutter/material.dart';
import 'package:frontend/src/models/user_model.dart';
import 'package:frontend/src/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotifier with ChangeNotifier {
  final darkTheme = <String, Color>{
    "COLOR_APPBAR": Color.fromARGB(255, 10, 11, 14),
    "COLOR_BACKGROUND": Color.fromARGB(255, 13, 17, 23),
    "COLOR_PANEL": Color.fromARGB(255, 17, 19, 22),
    "COLOR_ARCHIVED": Color.fromARGB(255, 22, 13, 6),
    "COLOR_BORDER": Colors.grey.shade600,
    "COLOR_TEXT": Colors.white,
  };
  final lightTheme = <String, Color>{
    "COLOR_APPBAR": Colors.grey.shade900,
    "COLOR_BACKGROUND": Colors.grey.shade300,
    "COLOR_PANEL": Colors.grey.shade100,
    "COLOR_ARCHIVED": Colors.amber.shade100,
    "COLOR_BORDER": Colors.grey.shade900,
    "COLOR_TEXT": Colors.black,
  };
  final String COLOR_APPBAR = "COLOR_APPBAR";
  final String COLOR_BACKGROUND = "COLOR_BACKGROUND";
  final String COLOR_PANEL = "COLOR_PANEL";
  final String COLOR_ARCHIVED = "COLOR_ARCHIVED";
  final String COLOR_BORDER = "COLOR_BORDER";
  final String COLOR_TEXT = "COLOR_TEXT";

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final keyToken = 'token';
  final keyDarkMode = 'dark_mode';

  late User _currentUser;
  late bool _isLoggedIn;
  late bool _isDarkMode;
  Map<String, Color>? _themeData;

  bool get isDarkMode => _isDarkMode;
  bool get isLoggedIn => _isLoggedIn;
  Color getColor(String color) => _themeData![color]!;
  User get currentUser => _currentUser;

  UserNotifier() {
    _isLoggedIn = false;
    _isDarkMode = false;
    _themeData = lightTheme;
  }

  void loadUser(User? user, BuildContext context) async {
    SharedPreferences preferences = await _prefs;
    bool? preferDarkMode = preferences.getBool(keyDarkMode);

    if (preferDarkMode != null) {
      preferDarkMode ? setDarkMode() : setLightMode();
    }
    if (user != null) {
      setUser(user);
      return;
    }
    if (user == null && preferDarkMode == null) {
      if (MediaQuery.platformBrightnessOf(context) == Brightness.light) return;
      setDarkMode();
    }
  }

  void logout() {
    _prefs.then((SharedPreferences prefs) {
      return prefs.remove(keyToken);
    }).then((bool successfulLogout) {
      if (successfulLogout) {
        _isLoggedIn = false;
        notifyListeners();
      }
    });
  }

  void loginUser(String token) {
    getCurrentUser(token).then((User user) {
      setUser(user);
    });
  }

  void setUser(User user) {
    _currentUser = user;
    _isLoggedIn = true;
    if (user.usesDarkTheme) {
      _themeData = darkTheme;
      _isDarkMode = true;
    } else {
      _themeData = lightTheme;
      _isDarkMode = false;
    }
    notifyListeners();
  }

  void setDarkMode() async {
    SharedPreferences preferences = await _prefs;
    String? token = preferences.getString(keyToken);
    _themeData = darkTheme;
    _isDarkMode = true;
    notifyListeners();

    bool? preferDarkMode = preferences.getBool(keyDarkMode);
    if (preferDarkMode != null) {
      if (preferDarkMode) return;
    }
    preferences.setBool(keyDarkMode, true);
    if (token == null) return;
    updateUserTheme(token, true)
        .then((value) => null)
        .catchError((error) => null);
  }

  void setLightMode() async {
    SharedPreferences preferences = await _prefs;
    String? token = preferences.getString(keyToken);
    _themeData = lightTheme;
    _isDarkMode = false;
    notifyListeners();

    bool? preferDarkMode = preferences.getBool(keyDarkMode);
    if (preferDarkMode != null) {
      if (!preferDarkMode) return;
    }
    preferences.setBool(keyDarkMode, false);
    if (token == null) return;
    updateUserTheme(token, false)
        .then((value) => null)
        .catchError((error) => null);
  }
}

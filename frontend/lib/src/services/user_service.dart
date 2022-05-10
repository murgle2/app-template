import 'dart:convert';
import 'dart:io';
import 'package:frontend/resources/config.dart';
import 'package:frontend/src/models/token_model.dart';
import 'package:http/http.dart';
import 'package:frontend/src/models/user_model.dart';

Future<Token> login(String email, String password) async {
  var data = <String, String>{};
  data['grant_type'] = 'password';
  data['username'] = email;
  data['password'] = password;

  final response = await post(
    Uri.parse(API_URL + '/login/access-token'),
    headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: data,
  );

  if (response.statusCode == 200) {
    return Token.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 400) {
    throw Exception(jsonDecode(response.body)['detail']);
  } else {
    throw Exception('Failed to login');
  }
}

Future<Token> googleLogin(String token) async {
  final response = await post(
    Uri.parse(API_URL + '/google'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'token': token}),
  );

  if (response.statusCode == 200) {
    return Token.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 400) {
    throw Exception(jsonDecode(response.body)['detail']);
  } else {
    throw Exception('Failed to login');
  }
}

Future<Token> appleLogin(String token) async {
  final response = await post(
    Uri.parse(API_URL + '/apple'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'token': token}),
  );

  if (response.statusCode == 200) {
    return Token.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 400) {
    throw Exception(jsonDecode(response.body)['detail']);
  } else {
    throw Exception('Failed to login');
  }
}

Future<String> requestVerifyEmail(String email) async {
  final response = await post(
    Uri.parse(API_URL + '/request-verify/' + email),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['msg'];
  } else if (response.statusCode == 404) {
    throw Exception('There is no account with this email address');
  } else {
    throw Exception('Failed to send email');
  }
}

Future<String> verifyEmail(String token) async {
  final response = await post(
    Uri.parse(API_URL + '/verify-email'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'token': token}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['msg'];
  } else if (response.statusCode == 400) {
    throw Exception('The link has expired');
  } else {
    throw Exception('Failed to verify email');
  }
}

Future<String> requestResetPassword(String email) async {
  final response = await post(
    Uri.parse(API_URL + '/password-recovery/' + email),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['msg'];
  } else if (response.statusCode == 404) {
    throw Exception('There is no account with this email address');
  } else {
    throw Exception('Failed to send email');
  }
}

Future<String> resetPassword(String password, String token) async {
  final response = await post(
    Uri.parse(API_URL + '/reset-password'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body:
        jsonEncode(<String, String>{'new_password': password, 'token': token}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['msg'];
  } else if (response.statusCode == 400) {
    throw Exception('The link has expired');
  } else {
    throw Exception('Failed to reset password');
  }
}

Future<User> createAccount(String email, String password) async {
  final response = await post(
    Uri.parse(API_URL + '/api/user'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'email': email, 'password': password}),
  );

  if (response.statusCode == 201) {
    return User.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 400) {
    throw Exception('Email address is already in use');
  } else {
    throw Exception('Failed to create account');
  }
}

Future<User> getCurrentUser(String token) async {
  final response =
      await get(Uri.parse(API_URL + '/api/user'), headers: <String, String>{
    HttpHeaders.authorizationHeader: 'Bearer ' + token,
    'Content-Type': 'application/json; charset=UTF-8',
  });

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 403) {
    throw Exception('Login expired');
  } else {
    throw Exception('Failed to get user');
  }
}

Future<String> updateUserTheme(String token, bool usesDarkTheme) async {
  final response = await patch(
      Uri.parse(API_URL + '/api/user/darkTheme/' + usesDarkTheme.toString()),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
        'Content-Type': 'application/json; charset=UTF-8',
      });

  if (response.statusCode == 200) {
    return jsonDecode(response.body)["msg"];
  } else {
    throw Exception('Failed to update theme');
  }
}

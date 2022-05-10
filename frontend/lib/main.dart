import 'package:flutter/material.dart';
import 'package:frontend/resources/configure_nonweb.dart'
    if (dart.library.html) 'package:frontend/resources/configure_web.dart';
import 'package:frontend/src/app.dart';

void main() {
  configureApp();
  runApp(App());
}

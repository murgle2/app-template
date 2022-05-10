import 'package:flutter/material.dart';

const String APP_NAME = "NAME ME";

const ROUTE_HOME = '/';
const ROUTE_ABOUT = '/about';
const ROUTE_PRIVACY = '/privacy';

Color COLOR_TRANSPARENT = Colors.grey.shade200.withOpacity(0.87);
Color COLOR_RED = Colors.redAccent.shade700;
Color COLOR_TEAL = Colors.tealAccent;

const API_URL =
    String.fromEnvironment('API_URL', defaultValue: 'http://localhost');

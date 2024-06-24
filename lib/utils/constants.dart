import 'package:flutter/material.dart';

const double kTabletWidth = 520;
const double kIconHeight = 24;
final kLightTheme = ThemeData.from(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
  ),
);
final kDarkTheme = ThemeData.from(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
);

const double kSpaceBtwWidgetsInPreviewOrRichTextEditor = 10;

const String backendRootUrl = 'text-call-backend.onrender.com';

const Color primaryFlushBarColor = Color.fromARGB(255, 0, 63, 114);

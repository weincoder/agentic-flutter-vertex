import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  double fontSizeFactor = 1;
  String fontFamily = 'Georgia';
  Color appColor = Colors.yellow;
  ThemeData appTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.black12),
  );

  AppState();

  // Configure the font size factor
  double setFontSizeFactor(double newValue) {
    fontSizeFactor = newValue;
    notifyListeners();

    return fontSizeFactor;
  }

  // Increase font size factor
  void increaseFontSizeFactor() {
    fontSizeFactor += .05;
    notifyListeners();
  }

  // Change font family
  String setFontFamily(String newFontFamily) {
    fontFamily = newFontFamily;
    notifyListeners();
    return fontFamily;
  }

  // Change app theme color
  Color setAppColor(Color newColor) {
    appColor = newColor;
    appTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: appColor,
        brightness: Brightness.light,
      ),
    );
    notifyListeners();

    return appColor;
  }
}

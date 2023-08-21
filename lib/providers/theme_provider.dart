import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return themeMode == ThemeMode.dark;
    }
  }

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AppColors {
  static const Color primaryColor = Color.fromARGB(255, 255, 179, 0);
  static const Color backgraundColor = Color(0xFF1B1B1B);
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  static const Color errorColor = Colors.red;
  static const Color darkGreyColor = Color.fromARGB(255, 120, 120, 120);
  static const Color lightGreyColor = Color.fromARGB(255, 169, 169, 169);
  static const Color saleColor = Color.fromARGB(255, 201, 76, 76);
}

class MyThemes {
  static final darkTheme = ThemeData(
    colorScheme: const ColorScheme.dark(),
    appBarTheme: const AppBarTheme(
      color: AppColors.backgraundColor,
    ),
    scaffoldBackgroundColor: AppColors.backgraundColor,
    primaryColor: Colors.white,
    cardColor: const Color.fromARGB(255, 46, 46, 46),
    iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 179, 0)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgraundColor,
      selectedIconTheme: IconThemeData(
        color: Color.fromARGB(255, 228, 228, 228),
      ),
      unselectedIconTheme: IconThemeData(
        color: Color.fromARGB(255, 88, 88, 88),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'MA'),
    ),
  );

  static final lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(),
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
    primaryColor: Colors.black,
    cardColor: const Color.fromARGB(255, 239, 239, 239),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'MA'),
    ),
    iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(iconColor: MaterialStatePropertyAll(Colors.black))),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      selectedIconTheme: IconThemeData(
        color: Colors.black,
      ),
      unselectedIconTheme: IconThemeData(
        color: Color.fromARGB(255, 193, 193, 193),
      ),
    ),
  );
}

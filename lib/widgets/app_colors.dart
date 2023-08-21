import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';

// class AppColors {
//   static const Color primary = Color.fromARGB(255, 255, 179, 0);
//   static const Color background = Color(0xFF1B1B1B);
//   static const Color white = Colors.white;
//   static const Color black = Colors.black;
//   static const Color error = Colors.red;
//   static const Color darkGrey = Color.fromARGB(255, 120, 120, 120);
//   static const Color lightGrey = Color.fromARGB(255, 169, 169, 169);
//   static const Color bottomNavBarUnselected = Color.fromARGB(255, 88, 88, 88);
//   static const Color bottomNavBarSelected = Color.fromARGB(255, 228, 228, 228);
//   static const Color sale = Color.fromARGB(255, 201, 76, 76);
// }

// class AppTheme {
//   static ThemeData lightTheme = ThemeData(
//     primaryColor: AppColors.primary,
//     scaffoldBackgroundColor: AppColors.background,
//     primaryColorDark: AppColors.darkGrey,
//     primaryColorLight: AppColors.lightGrey,
//     colorScheme: const ColorScheme.light(
//       primary: AppColors.primary,
//       background: AppColors.background,
//       error: AppColors.error,
//     ),
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       unselectedItemColor: AppColors.bottomNavBarUnselected,
//       selectedItemColor: AppColors.bottomNavBarSelected,
//     ),
//   );

//   static ThemeData darkTheme = ThemeData.dark().copyWith(
//     primaryColor: AppColors.primary,
//     scaffoldBackgroundColor: AppColors.background,
//     primaryColorDark: AppColors.darkGrey,
//     primaryColorLight: AppColors.lightGrey,
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       unselectedItemColor: AppColors.bottomNavBarUnselected,
//       selectedItemColor: AppColors.bottomNavBarSelected,
//     ),
//     colorScheme: const ColorScheme.dark(
//       primary: AppColors.primary,
//       background: AppColors.background,
//       error: AppColors.error,
//     ),
//   );
// }

// class ThemeProvider extends ChangeNotifier {
//   ThemeMode themeMode = ThemeMode.system;

//   bool get isDarkMode {
//     if (themeMode == ThemeMode.system) {
//       final brightness = SchedulerBinding.instance.window.platformBrightness;
//       return brightness == Brightness.dark;
//     } else {
//       return themeMode == ThemeMode.dark;
//     }
//   }

//   void toggleTheme(bool isOn) {
//     themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }
// }

// class MyThemes {
//   static final darkTheme = ThemeData(
//     scaffoldBackgroundColor: Colors.grey.shade900,
//     primaryColor: Colors.black,
//     colorScheme: const ColorScheme.dark(),
//     iconTheme: IconThemeData(color: Colors.purple.shade200, opacity: 0.8),
//   );

//   static final lightTheme = ThemeData(
//     scaffoldBackgroundColor: Colors.white,
//     primaryColor: Colors.white,
//     colorScheme: const ColorScheme.light(),
//     iconTheme: const IconThemeData(color: Colors.red, opacity: 0.8),
//   );
// }

class AppColors {
  static const Color primaryColor = Color.fromARGB(255, 255, 179, 0);
  static const Color backgraundColor = Color(0xFF1B1B1B);
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  static const Color errorColor = Colors.red;
  static const Color darkGreyColor = Color.fromARGB(255, 120, 120, 120);
  static const Color lightGreyColor = Color.fromARGB(255, 169, 169, 169);

  static const Color bottomNavBarUnselected = Color.fromARGB(255, 88, 88, 88);
  static const Color bottomNavBarSelected = Color.fromARGB(255, 228, 228, 228);

  static const Color saleColor = Color.fromARGB(255, 201, 76, 76);
}

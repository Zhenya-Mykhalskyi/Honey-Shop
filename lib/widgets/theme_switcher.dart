import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:honey/providers/theme_provider.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Switch(
      value: themeProvider.isDarkMode,
      onChanged: (value) {
        final provider = Provider.of<ThemeProvider>(context, listen: false);
        provider.toggleTheme(value);
      },
      activeColor: AppColors.blackColor,
      inactiveTrackColor: AppColors.primaryColor.withOpacity(0.3),
      activeThumbImage: const AssetImage('assets/img/moon.png'),
      inactiveThumbImage: const AssetImage('assets/img/sun.png'),
    );
  }
}

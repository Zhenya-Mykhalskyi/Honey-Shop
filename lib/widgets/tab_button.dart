import 'package:flutter/material.dart';

import 'package:honey/providers/theme_provider.dart';

class TabButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const TabButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme = Theme.of(context);
    return TextButton(
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isActive ? Colors.transparent : currentTheme.primaryColor,
              width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            text,
            style: TextStyle(
                fontFamily: 'MA',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? AppColors.blackColor
                    : currentTheme.textTheme.bodyMedium!.color),
          ),
        ),
      ),
    );
  }
}

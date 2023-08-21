import 'package:flutter/material.dart';

class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showIconButton;
  final IconData? icon;
  final Function? action;

  const TitleAppBar(
      {Key? key,
      required this.title,
      this.showIconButton = false,
      this.icon,
      this.action})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme = Theme.of(context);
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: currentTheme.primaryColor),
      ),
      elevation: 0,
      centerTitle: true,
      actions: [
        if (showIconButton)
          IconButton(
            onPressed: () {
              if (action != null) {
                action!();
              }
            },
            icon: Icon(
              icon,
              size: 28,
              color: currentTheme.primaryColor,
            ),
          ),
      ],
    );
  }
}

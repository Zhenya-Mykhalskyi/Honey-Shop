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
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
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
            icon: Icon(icon),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class TitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const TitleAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // automaticallyImplyLeading:
      //     false, //ігнорування кнопка назад при розміщенні title
      // title: Text(title),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/img/appbar_title_left.png'),
          Text(title),
          Image.asset('assets/img/appbar_title_right.png'),
          const SizedBox(width: 40)
        ],
      ),
      elevation: 0,
      centerTitle: true,
    );
  }
}

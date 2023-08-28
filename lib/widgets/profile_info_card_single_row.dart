import 'package:flutter/material.dart';

class ProfileInfoCardSingleRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final bool? showInfoIcon;
  const ProfileInfoCardSingleRow({
    super.key,
    required this.icon,
    required this.text,
    this.color,
    this.fontWeight,
    this.showInfoIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color ?? Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
                fontSize: 15,
                color: color ?? Theme.of(context).primaryColor,
                fontWeight: fontWeight ?? FontWeight.w500),
          ),
        ),
        if (showInfoIcon == true)
          Tooltip(
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            textStyle:
                TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
            triggerMode: TooltipTriggerMode.tap,
            showDuration: const Duration(seconds: 5),
            message:
                'Чим більша загальна сума Ваших успішних замовлень, тим більший відсоток нарахування бонусів*',
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Icon(Icons.info_outline,
                  color: Theme.of(context).primaryColor, size: 13),
            ),
          ),
      ],
    );
  }
}

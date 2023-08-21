import 'package:flutter/material.dart';

import 'package:honey/providers/theme_provider.dart';

class CustomButton extends StatelessWidget {
  final void Function() action;
  final String text;
  final double? width;
  final EdgeInsetsGeometry? margin;
  const CustomButton(
      {super.key,
      required this.action,
      required this.text,
      this.width,
      this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 25, top: 30),
      width: width ?? MediaQuery.of(context).size.width * 0.9,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(AppColors.primaryColor),
        ),
        onPressed: action,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            text,
            style: TextStyle(
                color: AppColors.blackColor.withOpacity(0.8),
                fontFamily: 'MA',
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
      ),
    );
  }
}

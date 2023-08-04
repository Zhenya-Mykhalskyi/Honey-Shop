import 'package:flutter/material.dart';

import 'app_colors.dart';

class CustomTextField extends StatelessWidget {
  final int maxLength;
  final String? Function(String?)? validator;
  final TextEditingController controller;

  final String? hintText;
  final String? sufixText;
  final Widget? prefix;
  final double? textSize;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool showCounterText;
  final bool showHintText;
  final bool isTextAlignCenter;

  const CustomTextField({
    super.key,
    required this.maxLength,
    required this.controller,
    required this.validator,
    this.hintText,
    this.sufixText,
    this.prefix,
    this.textSize,
    this.keyboardType,
    this.maxLines,
    this.showCounterText = false,
    this.showHintText = true,
    this.isTextAlignCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHintText)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                hintText ?? '',
                style: const TextStyle(
                  color: Color.fromARGB(255, 169, 169, 169),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryColor,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextFormField(
              textAlign: isTextAlignCenter ? TextAlign.center : TextAlign.start,
              validator: validator,
              cursorColor: AppColors.primaryColor,
              maxLines: maxLines ?? 1,
              controller: controller,
              maxLength: maxLength,
              keyboardType: keyboardType,
              style: TextStyle(color: Colors.white, fontSize: textSize ?? 21),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(8),
                counterText: showCounterText ? null : '',
                counterStyle: const TextStyle(color: Colors.white),
                border: InputBorder.none,
                prefix: prefix,
                prefixStyle:
                    TextStyle(color: Colors.white, fontSize: textSize ?? 21),
                suffixText: sufixText,
                suffixStyle: TextStyle(
                    color: Colors.white,
                    fontSize: textSize ?? 18,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final String? sufixText;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final int maxLength;
  final int? maxLines;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool showCounterText;
  final bool showHintText;
  final bool isTextAlignCenter;

  const CustomTextField({
    super.key,
    this.hintText,
    this.sufixText,
    this.prefix,
    this.keyboardType,
    required this.maxLength,
    this.maxLines,
    required this.controller,
    required this.validator,
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
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(8),
                counterText: showCounterText ? null : '',
                counterStyle: const TextStyle(color: Colors.white),
                border: InputBorder.none,
                prefix: prefix,
                prefixStyle: const TextStyle(color: Colors.white, fontSize: 18),
                suffixText: sufixText,
                suffixStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

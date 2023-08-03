import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;

  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback onConfirm;
  final Color? confirmButtonColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.confirmButtonText,
    required this.cancelButtonText,
    required this.onConfirm,
    this.confirmButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 27, 27, 27),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'MA',
              ),
            ),
            const SizedBox(height: 15),
            ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: onConfirm,
                  child: Text(
                    confirmButtonText,
                    style: TextStyle(
                        color: confirmButtonColor ?? Colors.red,
                        fontFamily: 'MA'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    cancelButtonText,
                    style:
                        const TextStyle(color: Colors.white, fontFamily: 'MA'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

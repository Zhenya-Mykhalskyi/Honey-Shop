import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final void Function() action;
  final String text;
  const CustomButton({required this.action, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 50, top: 30),
      width: MediaQuery.of(context).size.width * 0.9,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          backgroundColor:
              MaterialStateProperty.all(const Color.fromARGB(255, 255, 179, 0)),
        ),
        onPressed: action,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            text,
            style: const TextStyle(
                color: Color.fromARGB(255, 74, 43, 41),
                fontFamily: 'MA',
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
      ),
    );
  }
}

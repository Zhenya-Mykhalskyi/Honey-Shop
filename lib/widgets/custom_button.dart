import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final void Function() action;
  const CustomButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(30),
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
        child: const Padding(
          padding: EdgeInsets.all(15.0),
          child: Text(
            'Зареєструватися',
            style: TextStyle(
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

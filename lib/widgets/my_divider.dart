import 'package:flutter/material.dart';

class MyDivider extends StatelessWidget {
  final Color color;
  final double? verticalPadding;

  const MyDivider({
    Key? key,
    this.color = Colors.white,
    this.verticalPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 10.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 10),
              child: SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color.withOpacity(0.2)),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

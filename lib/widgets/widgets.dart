import 'package:flutter/material.dart';
import 'package:lotto/widgets/text.dart';

class Space extends StatelessWidget {
  final double size;

  const Space(this.size);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
    );
  }
}

class LottoBall extends StatelessWidget {
  final num? number;

  final Color? backgroundColor;

  final Color? textColor;

  final bool useShadow;

  const LottoBall(this.number,
      {this.backgroundColor, this.textColor, this.useShadow = true});

  Color getBallColor(int number) {
    if (number >= 1 && number <= 10) return Colors.yellow;
    if (number >= 11 && number <= 20) return Colors.blue;
    if (number >= 21 && number <= 30) return Colors.red;
    if (number >= 31 && number <= 40) return Colors.black;
    if (number >= 41 && number <= 45) return Colors.green;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.width * 0.1,
      alignment: Alignment.center,
      child: LottoText(
        number.toString(),
        color: textColor == null ? Colors.white : textColor,
        shadows: useShadow == true
            ? [
                Shadow(
                  offset: Offset(0.0, 0.0),
                  blurRadius: 2,
                  color: Color.fromARGB(125, 0, 0, 0),
                )
              ]
            : [],
      ),
      decoration: BoxDecoration(
          color: backgroundColor == null
              ? getBallColor(number as int)
              : backgroundColor,
          borderRadius: BorderRadius.circular(50)),
    );
  }
}

import 'package:flutter/material.dart';

enum TextType { Light, Regular, Bold, ExtraBold }

FontWeight getWeightFromType(TextType type) {
  if (type == TextType.Light) return FontWeight.w400;
  if (type == TextType.Regular) return FontWeight.w400;
  if (type == TextType.Bold) return FontWeight.w700;
  if (type == TextType.ExtraBold) return FontWeight.w800;
  return FontWeight.normal;
}

class TextBinggrae extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;
  final double height;
  final TextType type;
  final TextAlign align;
  final TextOverflow overflow;
  final List<Shadow> shadows;
  final int? maxLines;

  const TextBinggrae(
    this.text, {super.key, 
    this.color = Colors.black,
    this.size = 14,
    this.height = 1.5,
    this.type = TextType.Regular,
    this.align = TextAlign.center,
    this.overflow = TextOverflow.ellipsis,
    this.shadows = const [],
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      overflow: overflow,
      maxLines: maxLines,
      style: TextStyle(
          color: color,
          fontSize: size,
          height: height,
          fontWeight: getWeightFromType(type),
          shadows: shadows,
          fontFamily: 'Binggrae'),
    );
  }
}

class LottoText extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;
  final double height;
  final TextType type;
  final TextAlign align;
  final TextOverflow overflow;
  final List<Shadow> shadows;
  final int? maxLines;
  final String? fontFamily;

  const LottoText(
    this.text, {super.key, 
    this.color = Colors.black,
    this.size = 14,
    this.height = 1.5,
    this.type = TextType.Regular,
    this.align = TextAlign.center,
    this.overflow = TextOverflow.ellipsis,
    this.shadows = const [],
    this.maxLines,
    this.fontFamily = 'NexonLv2',
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      overflow: overflow,
      maxLines: maxLines,
      style: TextStyle(
          color: color,
          fontSize: size,
          height: height,
          fontWeight: getWeightFromType(type),
          shadows: shadows,
          fontFamily: fontFamily),
    );
  }
}

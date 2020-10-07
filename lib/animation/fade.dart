import 'package:flutter/material.dart';

class FadeInOffset extends StatefulWidget {

  final int delayInMilisecond;
  final Duration duration;
  final Offset offset;
  final Widget child;

  const FadeInOffset({this.delayInMilisecond = 0, this.duration = const Duration(milliseconds: 500), this.offset = const Offset(0, 0), @required this.child});

  @override
  FadeInOffsetState createState() => FadeInOffsetState();
}

class FadeInOffsetState extends State<FadeInOffset> with SingleTickerProviderStateMixin{

  AnimationController controller;
  Animation<double> fadeAnimation;
  Animation<Offset> offsetAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: widget.duration);
    controller.addListener(() {setState(() {});});
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    offsetAnimation = Tween<Offset>(begin: widget.offset, end: Offset(0, 0)).animate(controller);
    Future.delayed(Duration(milliseconds: widget.delayInMilisecond), () {
      if (controller != null)
        controller.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offsetAnimation.value,
      child: Opacity(
        opacity: fadeAnimation.value,
        child: widget.child,
      ),
    );
  }
}
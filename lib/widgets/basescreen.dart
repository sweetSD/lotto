import 'package:flutter/material.dart';
import 'package:lotto/widgets/text.dart';

class BaseScreen extends StatelessWidget {

  final AppBar appBar;

  final String title;

  final bool centerTitle;

  final bool resizeToAvoidBottomInset;

  final Widget body;

  final Widget leading;

  final List<Widget> actions;

  const BaseScreen({
    Key key, 
    this.appBar, 
    this.title = '',
    this.centerTitle = true,
    this.resizeToAvoidBottomInset = true,
    this.body,
    this.leading,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar != null ? appBar : AppBar(
        backgroundColor: Colors.white,
        title: TextBinggrae(title, size: 18,),
        centerTitle: centerTitle,
        leading: leading != null ? leading : IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black,),
        ),
        actions: actions != null ? actions : [],
      ),
      body: body,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';

YYDialog buildDialog(BuildContext context, Widget child) {
  YYDialog.init(context);
  return YYDialog().build()
    ..backgroundColor = Colors.transparent
    ..widget(child);
}
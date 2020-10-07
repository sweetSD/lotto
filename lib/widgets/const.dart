import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

NumberFormat get currencyFormat => NumberFormat('###,###,###,###');

BoxDecoration roundBoxDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [BoxShadow(color: Color(0xffcccccc), blurRadius: 1.0, spreadRadius: 1.0, offset: Offset(0, 1))]
  );
}
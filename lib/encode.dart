import 'dart:async';
import 'package:flutter/services.dart';

class UrlEncoder {
  static const MethodChannel _platform = const MethodChannel('_ENCODING');

  Future<String> encode(String data, [String encoding = 'utf-8']) async {
    var res = data;
    try {
      res = await _platform.invokeMethod('encode', [data, encoding].toList());
    } catch (e) {
      print(e);
      return Future<String>.error(e);
    }
    return Future<String>.value(res);
  }

  Future<String> decode(String data, [String encoding = 'utf-8']) async {
    var res = data;
    try {
      res = await _platform.invokeMethod('decode', [data, encoding].toList());
    } catch (e) {
      print(e);
      return Future<String>.error(e);
    }
    return Future<String>.value(res);
  }
}
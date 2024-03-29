import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _UrlEncoder {
  static const MethodChannel _platform = MethodChannel('_ENCODING');

  Future<String> encode(String data, [String encoding = 'utf-8']) async {
    String? res = data;
    try {
      res = await _platform.invokeMethod('encode', [data, encoding].toList());
    } catch (e) {
      debugPrint(e.toString());
      return Future<String>.error(e);
    }
    return Future<String>.value(res);
  }

  Future<String> decode(String data, [String encoding = 'utf-8']) async {
    String? res = data;
    try {
      res = await _platform.invokeMethod('decode', [data, encoding].toList());
    } catch (e) {
      debugPrint(e.toString());
      return Future<String>.error(e);
    }
    return Future<String>.value(res);
  }

  Future<Uint8List> encodeByte(String data, [String encoding = 'utf-8']) async {
    Uint8List? res = [] as Uint8List;
    try {
      res = await (_platform.invokeMethod(
          'encodeByte', [data, encoding].toList()));
    } catch (e) {
      debugPrint(e.toString());
      return Future<Uint8List>.error(e);
    }
    return Future<Uint8List>.value(res);
  }

  Future<String> decodeByte(Uint8List data, [String encoding = 'utf-8']) async {
    String? res = '';
    try {
      res = await (_platform.invokeMethod(
          'decodeByte', [data, encoding].toList()));
    } catch (e) {
      debugPrint(e.toString());
      return Future<String>.error(e);
    }
    return Future<String>.value(res);
  }
}

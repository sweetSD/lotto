import 'package:async/async.dart';

import 'package:flutter/material.dart';
import 'package:lotto/network/network.dart';
import 'package:lotto/widgets/basescreen.dart';

class HoroscopePage extends StatefulWidget {
  HoroscopePage({Key key}) : super(key: key);

  @override
  _HoroscopePageState createState() => _HoroscopePageState();
}

class _HoroscopePageState extends State<HoroscopePage> {

  final AsyncMemoizer<void> _asyncMemoizer = AsyncMemoizer<void>();

  Future<void> getHoroscope() {
    return _asyncMemoizer.runOnce(() async {
      NetworkUtil().getHoroscope();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '오늘의 띠별 운세',
      body: FutureBuilder(
        future: getHoroscope(),
        builder: (context, snapshot) {
          return Container();
        },
      ),
    );
  }
}
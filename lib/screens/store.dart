import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:lotto/widgets/basescreen.dart';
import 'package:lotto/widgets/text.dart';

class LottoStorePage extends StatefulWidget {
  LottoStorePage({Key key}) : super(key: key);

  @override
  _LottoStorePageState createState() => _LottoStorePageState();
}

class _LottoStorePageState extends State<LottoStorePage> {

  final String _storeUrl = 'https://m.dhlottery.co.kr/store.do?method=topStore&pageGubun=L645';

  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() { 

    flutterWebviewPlugin.onUrlChanged.listen((event) { 
      if(!event.contains('m.dhlottery.co.kr/store.do?method=topStore')) {
        flutterWebviewPlugin.goBack();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    flutterWebviewPlugin.launch(_storeUrl, rect: Rect.fromLTWH(0, -115, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height + 115));

    return WillPopScope(
      onWillPop: () async {
        print(await flutterWebviewPlugin.canGoBack());
        if(await flutterWebviewPlugin.canGoBack()) {
          await flutterWebviewPlugin.goBack();
          return Future<bool>.value(false);
        } else { 
          await flutterWebviewPlugin.close();
          return Future<bool>.value(true);
        }
      },
      child: BaseScreen(
        body: Container(),
      ),
    );
  }
}
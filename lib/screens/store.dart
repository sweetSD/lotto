import 'dart:async';
import 'package:async/async.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lotto/animation/fade.dart';
import 'package:lotto/network/network.dart';
import 'package:lotto/network/place.dart';
import 'package:lotto/widgets/basescreen.dart';
import 'package:lotto/widgets/const.dart';
import 'package:lotto/widgets/text.dart';
import 'package:lotto/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LottoStorePage extends StatefulWidget {
  LottoStorePage({Key? key}) : super(key: key);

  @override
  _LottoStorePageState createState() => _LottoStorePageState();
}

class _LottoStorePageState extends State<LottoStorePage> {
  final String _storeUrl =
      'https://m.dhlottery.co.kr/store.do?method=topStore&pageGubun=L645';

  final controller = WebViewController();

  @override
  void initState() {
    super.initState();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (!request.url
                .contains('m.dhlottery.co.kr/store.do?method=topStore')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_storeUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Simple Example')),
      body: WebViewWidget(controller: controller),
    );
  }
}

class LottoRankStorePage extends StatefulWidget {
  LottoRankStorePage({Key? key}) : super(key: key);

  @override
  _LottoRankStorePageState createState() => _LottoRankStorePageState();
}

class _LottoRankStorePageState extends State<LottoRankStorePage> {
  AsyncMemoizer<List<LottoStore>> _asyncMemoizer =
      AsyncMemoizer<List<LottoStore>>();

  int _nowPage = 1;

  List<LottoStore> _stores = [];

  Future<List<LottoStore>> getLottoStore() {
    return _asyncMemoizer.runOnce(() async {
      var list = await NetworkUtil().getLottoTopStoreRank(_nowPage);
      if (list.length > 0) {
        _stores.addAll(list);
      } else {
        Fluttertoast.showToast(msg: '마지막 페이지입니다.');
      }
      return _stores;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '당첨자 배출점 조회',
      body: FutureBuilder<List<LottoStore>>(
        future: getLottoStore(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;

            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => FadeInOffset(
                        offset: Offset(0, 50),
                        child: GestureDetector(
                          onTap: () async {
                            if (await canLaunch(
                                'https://dhlottery.co.kr/store.do?method=topStoreLocation&gbn=lotto&rtlrId=${data?[index].storeId}')) {
                              launch(
                                  'https://dhlottery.co.kr/store.do?method=topStoreLocation&gbn=lotto&rtlrId=${data?[index].storeId}');
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            decoration: roundBoxDecoration(),
                            margin: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child:
                                      LottoText(data![index].index.toString()),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LottoText(data[index].name),
                                      LottoText(
                                          '1등 당첨: ${data[index].winCount}회'),
                                      LottoText(
                                        data[index].address,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                    itemCount: data!.length,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _nowPage++;
                        _asyncMemoizer = AsyncMemoizer<List<LottoStore>>();
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration: roundBoxDecoration(),
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Center(
                        child: LottoText('더보기'),
                      ),
                    ),
                  ),
                  Space(50),
                ],
              ),
            );
          } else {
            return Center(
              child: LottoText('목록을 불러오는 중입니다..'),
            );
          }
        },
      ),
    );
  }
}

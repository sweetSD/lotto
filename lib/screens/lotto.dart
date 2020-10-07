import 'dart:convert';
import 'package:async/async.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotto/network/lotto.dart';
import 'package:lotto/network/network.dart';
import 'package:lotto/widgets/basescreen.dart';
import 'package:lotto/widgets/lotto.dart';
import 'package:lotto/widgets/text.dart';

class LottoQRResultPage extends StatefulWidget {

  final String qrCodeUrl;

  const LottoQRResultPage(this.qrCodeUrl);

  @override
  _LottoQRResultPageState createState() => _LottoQRResultPageState();
}

class _LottoQRResultPageState extends State<LottoQRResultPage> {

  final AsyncMemoizer<LottoQRResult> _asyncMemoizer = AsyncMemoizer<LottoQRResult>();

  Future<LottoQRResult> getQRCodeResult() {
    return _asyncMemoizer.runOnce(() async {
      return NetworkUtil().getLottoQRCodeResult(widget.qrCodeUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'QR코드 당첨 결과',
      body: FutureBuilder<LottoQRResult>(
        future: getQRCodeResult(),
        builder: (context, snapshot) {
          LottoQRResult result = snapshot.data;
          if(snapshot.hasData) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(bottom: 50),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    LottoWinResultWidget(result.lotto),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if(result.prize > 0) ... [
                            TextBinggrae('축하합니다!'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                  TextBinggrae('총 '),
                                  TextBinggrae('${NumberFormat('###,###,###,###').format(result.prize)}원', color: Colors.blue,),
                                  TextBinggrae(' 당첨'),
                              ],
                            ),
                          ] else ... [
                            TextBinggrae('아쉽게도 낙첨 되셨습니다.'),
                          ]
                        ],
                      ),
                    ),
                    for(int i = 0; i < result.picks.length; i++) ... [
                      LottoPickWidget(result.picks[i].pickNumbers, index: i, rank: result.picks[i].result, color: i % 2 == 1 ? Colors.white : Color(0xffeeeeee), result: result.lotto.numbers,),
                    ]
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasError) {
            return Center(child: CircularProgressIndicator(),);
          } else {
            return Center(child: TextBinggrae('당첨 결과를 조회 할 수 없습니다. :('),);
          }
        },
      ),
    );
  }
}
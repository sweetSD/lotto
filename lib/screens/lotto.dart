import 'dart:convert';
import 'package:async/async.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotto/network/lotto.dart';
import 'package:lotto/network/network.dart';
import 'package:lotto/widgets/basescreen.dart';
import 'package:lotto/widgets/const.dart';
import 'package:lotto/widgets/lotto.dart';
import 'package:lotto/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String qrBaseUrl = 'https://m.dhlottery.co.kr/qr.do?method=winQr&v=';

class LottoQRResultPage extends StatefulWidget {
  final String? qrCodeUrl;

  const LottoQRResultPage(this.qrCodeUrl, {super.key});

  @override
  _LottoQRResultPageState createState() => _LottoQRResultPageState();
}

class _LottoQRResultPageState extends State<LottoQRResultPage> {
  final AsyncMemoizer<LottoQRResult> _asyncMemoizer =
      AsyncMemoizer<LottoQRResult>();

  final List<LottoQRResult> _qrResults = [];

  Future<LottoQRResult> getQRCodeResult() {
    return _asyncMemoizer.runOnce(() async {
      LottoQRResult result = await NetworkUtil()
          .getLottoQRCodeResult(qrBaseUrl + widget.qrCodeUrl!.split('v=')[1]);

      var prefs = await NetworkUtil().preferenceAsync as SharedPreferences;
      if (prefs.containsKey('qrResults')) {
        var resultStrings = prefs.getStringList('qrResults')!;
        for (var element in resultStrings) {
          _qrResults.add(LottoQRResult.fromJson(jsonDecode(element)));
        }
      }

      if (_qrResults.any((element) => element.url == result.url)) {
        _qrResults.removeWhere((element) => element.url == result.url);
      }
      _qrResults.add(result);

      List<String> qrStrings = [];
      for (var element in _qrResults) {
        qrStrings.add(jsonEncode(element));
      }
      prefs.setStringList('qrResults', qrStrings);
    
      return result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'QR코드 당첨 결과',
      body: FutureBuilder<LottoQRResult>(
        future: getQRCodeResult(),
        builder: (context, snapshot) {
          LottoQRResult? result = snapshot.data;
          if (snapshot.hasData) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (result!.lotto != null) ...[
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: LottoWinResultWidget(result.lotto),
                      ),
                    ] else ...[
                      Container(
                        height: 75,
                        alignment: Alignment.center,
                        child: const LottoText('미추첨 복권입니다.'),
                      ),
                    ],
                    if (result.lotto != null) ...[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (result.prize! > 0) ...[
                              const LottoText('축하합니다!'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const LottoText('총 '),
                                  LottoText(
                                    '${NumberFormat('###,###,###,###').format(result.prize)}원',
                                    color: Colors.blue,
                                  ),
                                  const LottoText(' 당첨'),
                                ],
                              ),
                            ] else ...[
                              const LottoText('아쉽게도 낙첨 되셨습니다.'),
                            ]
                          ],
                        ),
                      ),
                    ],
                    for (int i = 0; i < result.picks.length; i++) ...[
                      LottoPickWidget(
                        result.picks[i].pickNumbers,
                        index: i,
                        rank: result.lotto != null
                            ? result.picks[i].result
                            : null,
                        color: i % 2 == 1 ? Colors.white : const Color(0xffeeeeee),
                        result: result.lotto?.numbers,
                      ),
                    ]
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasError) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return const Center(
              child: LottoText('당첨 결과를 조회 할 수 없습니다. :('),
            );
          }
        },
      ),
    );
  }
}

class LottoResultPage extends StatefulWidget {
  final Lotto lotto;

  final List<int> pickNumbers;

  const LottoResultPage(this.lotto, this.pickNumbers, {super.key});

  @override
  _LottoResultPageState createState() => _LottoResultPageState();
}

class _LottoResultPageState extends State<LottoResultPage> {
  int _rank = 0;

  void initResult() {
    int correctCount = 0;
    bool isCorrectBonus = false;
    if (widget.pickNumbers.contains(widget.lotto.drawNo1)) correctCount++;
    if (widget.pickNumbers.contains(widget.lotto.drawNo2)) correctCount++;
    if (widget.pickNumbers.contains(widget.lotto.drawNo3)) correctCount++;
    if (widget.pickNumbers.contains(widget.lotto.drawNo4)) correctCount++;
    if (widget.pickNumbers.contains(widget.lotto.drawNo5)) correctCount++;
    if (widget.pickNumbers.contains(widget.lotto.drawNo6)) correctCount++;
    if (correctCount == 5) {
      if (widget.pickNumbers.contains(widget.lotto.drawBonus)) {
        isCorrectBonus = true;
      }
    }
    if (correctCount == 3) _rank = 5;
    if (correctCount == 4) _rank = 4;
    if (correctCount == 5) _rank = 3;
    if (correctCount == 5 && isCorrectBonus) _rank = 2;
    if (correctCount == 6) _rank = 1;
  }

  @override
  void initState() {
    super.initState();
    initResult();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: '직접 입력 당첨 결과',
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: LottoWinResultWidget(widget.lotto),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (_rank > 0) ...[
                        const LottoText('축하합니다!'),
                        LottoText('$_rank등 당첨되셨습니다.'),
                      ] else ...[
                        const LottoText('아쉽게도 낙첨 되셨습니다.'),
                      ]
                    ],
                  ),
                ),
                LottoPickWidget(
                  widget.pickNumbers,
                  index: 0,
                  rank: _rank,
                  color: const Color(0xffeeeeee),
                  result: widget.lotto.numbers,
                ),
              ],
            ),
          ),
        ));
  }
}

class QRResultPage extends StatefulWidget {
  const QRResultPage({super.key});

  @override
  _QRResultPageeState createState() => _QRResultPageeState();
}

class _QRResultPageeState extends State<QRResultPage> {
  final AsyncMemoizer<List<LottoQRResult>> _asyncMemoizer =
      AsyncMemoizer<List<LottoQRResult>>();

  Future<List<LottoQRResult>> getQRResults() async {
    return _asyncMemoizer.runOnce(() async {
      List<LottoQRResult> result = [];
      var prefs = await NetworkUtil().preferenceAsync as SharedPreferences;
      if (prefs.containsKey('qrResults')) {
        var strList = prefs.getStringList('qrResults')!;
        for (var element in strList) {
          result.add(LottoQRResult.fromJson(jsonDecode(element)));
        }
      }
      debugPrint(result.length.toString());
      debugPrint(result.toString());
      return result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        title: 'QR코드 기록',
        body: FutureBuilder<List<LottoQRResult>>(
          future: getQRResults(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              var data = snapshot.data!;
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            padding: const EdgeInsets.only(top: 12),
                            decoration: roundBoxDecoration(),
                            child: InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LottoQRResultPage(data[index].url),
                                  )),
                              child: Column(
                                children: [
                                  if (data[index].lotto != null) ...[
                                    data[index].prize! > 0
                                        ? LottoText(
                                            '${NumberFormat('###,###,###,###').format(data[index].prize)}원 당첨되셨습니다.')
                                        : const LottoText('아쉽지만, 낙첨되셨습니다.'),
                                    LottoWinResultWidget(data[index].lotto,
                                        useDecoration: false),
                                  ] else ...[
                                    const LottoText('추첨이 진행되지 않았습니다.\n클릭하여 확인해보세요.'),
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: data.length,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: const Center(
                  child:
                      LottoText('저장된 QR코드가 없습니다.\n앱에서 QR코드를 스캔하면 자동으로 등록됩니다.'),
                ),
              );
            }
          },
        ));
  }
}

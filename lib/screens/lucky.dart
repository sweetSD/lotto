import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lotto/animation/fade.dart';
import 'package:lotto/const.dart';
import 'package:lotto/network/network.dart';
import 'package:lotto/screens/analyze.dart';
import 'package:lotto/widgets/basescreen.dart';
import 'package:lotto/widgets/const.dart';
import 'package:lotto/widgets/lotto.dart';
import 'package:lotto/widgets/text.dart';
import 'package:lotto/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LuckyBallPage extends StatefulWidget {
  const LuckyBallPage({Key? key}) : super(key: key);

  @override
  _LuckyBallPageState createState() => _LuckyBallPageState();
}

class _LuckyBallPageState extends State<LuckyBallPage> {
  final List<List<int>> _luckyNums = [];
  final String generatedLuckyNumCountKey = 'generatedLuckyNumbers';

  @override
  void initState() {
    if (NetworkUtil().preference!.containsKey('lucky')) {
      for (var element in NetworkUtil().preference!.getStringList('lucky')!) {
        _luckyNums.add(element.split(',').map((e) => int.parse(e)).toList());
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '행운 번호 추첨',
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            FontAwesomeIcons.chartBar,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyzePage(luckyBalls: _luckyNums),
                ));
          },
        )
      ],
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 500),
              firstChild: GestureDetector(
                onTap: () {
                  generateLuckyNumbers();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: roundBoxDecoration(),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      LottoText('당신만을 위한 행운의 추첨 번호를 준비하였습니다.'),
                      Space(50),
                      LottoText(
                        '행운 번호 받기',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              secondChild: GestureDetector(
                onTap: () {
                  generateLuckyNumbers();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: roundBoxDecoration(),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const LottoText('행운 번호가 생성되었습니다.'),
                      LottoPickWidget(
                        _luckyNums.isNotEmpty ? _luckyNums[0] : [],
                        onlyPicks: true,
                        color: Colors.white,
                      ),
                      const LottoText(
                        '행운 번호 다시 받기',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              crossFadeState: _luckyNums.isEmpty
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
            ),
            if (_luckyNums.length > 1) ...[
              const Divider(
                height: 30,
                thickness: 1,
              ),
              const FadeInOffset(
                delayInMilisecond: 250,
                offset: Offset(0, 10),
                child: LottoText('행운 번호 기록'),
              ),
              const Space(15),
              FadeInOffset(
                delayInMilisecond: 500,
                offset: const Offset(0, 10),
                child: ListView.separated(
                  separatorBuilder: (context, index) => const Divider(
                    thickness: 1,
                    height: 1,
                    color: Color(0xffcccccc),
                  ),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.125,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          LottoPickWidget(
                            _luckyNums.isNotEmpty ? _luckyNums[index + 1] : [],
                            onlyPicks: true,
                            color: Colors.transparent,
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: _luckyNums.length - 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void tryInterstitialAd() {
    InterstitialAd.load(
        adUnitId: admobLuckyID,
        request: const AdRequest(),
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          ad.show();
          generateNumbers();
        }, onAdFailedToLoad: (LoadAdError error) {
          Fluttertoast.showToast(msg: "오류가 발생하여 번호를 생성할 수 없습니다.");
        }));
  }

  Future<void> generateLuckyNumbers() async {
    String key = 'daily_lucky';
    var prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      var lastDate = DateTime.fromMillisecondsSinceEpoch(prefs.getInt(key)!);
      if (lastDate.day != DateTime.now().day &&
          !DateTime.now().difference(lastDate).isNegative) {
        tryInterstitialAd();
        prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
      } else {
        Fluttertoast.showToast(msg: "행운 번호는 하루 한 번 이용할 수 있습니다.");
      }
    } else {
      prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
      tryInterstitialAd();
    }
  }

  void generateNumbers() {
    Random random = Random();
    _luckyNums.insert(0, []);
    while (_luckyNums[0].length < 6) {
      var randNum = random.nextInt(45) + 1;
      if (_luckyNums[0].contains(randNum)) continue;
      _luckyNums[0].add(randNum);
    }
    setState(() {
      _luckyNums[0].sort();
    });
    List<String> saveList = [];
    for (var element in _luckyNums) {
      saveList.add(element.map((e) => e.toString()).toList().join(','));
    }
    NetworkUtil().preference!.setStringList('lucky', saveList);
  }
}

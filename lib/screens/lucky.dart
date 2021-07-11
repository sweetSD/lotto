import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lotto/animation/fade.dart';
import 'package:lotto/network/network.dart';
import 'package:lotto/screens/analyze.dart';
import 'package:lotto/screens/main.dart';
import 'package:lotto/widgets/basescreen.dart';
import 'package:lotto/widgets/const.dart';
import 'package:lotto/widgets/lotto.dart';
import 'package:lotto/widgets/text.dart';
import 'package:lotto/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LuckyBallPage extends StatefulWidget {
  LuckyBallPage({Key key}) : super(key: key);

  @override
  _LuckyBallPageState createState() => _LuckyBallPageState();
}

class _LuckyBallPageState extends State<LuckyBallPage> {
  List<List<int>> _luckyNums = [];
  final String generatedLuckyNumCountKey = 'generatedLuckyNumbers';

  @override
  void initState() {
    if (NetworkUtil().preference.containsKey('lucky')) {
      NetworkUtil().preference.getStringList('lucky').forEach((element) {
        _luckyNums.add(element.split(',').map((e) => int.parse(e)).toList());
      });
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
          icon: Icon(
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
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            AnimatedCrossFade(
              duration: Duration(milliseconds: 500),
              firstChild: GestureDetector(
                onTap: () {
                  generateLuckyNumbers();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: roundBoxDecoration(),
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextBinggrae('당신만을 위한 행운의 추첨 번호를 준비하였습니다.'),
                      Space(50),
                      TextBinggrae(
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
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextBinggrae('행운 번호가 생성되었습니다.'),
                      LottoPickWidget(
                        _luckyNums.length > 0 ? _luckyNums[0] : [],
                        onlyPicks: true,
                        color: Colors.white,
                      ),
                      TextBinggrae(
                        '행운 번호 다시 받기',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              crossFadeState: _luckyNums.length == 0
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
            ),
            if (_luckyNums.length > 1) ...[
              Divider(
                height: 30,
                thickness: 1,
              ),
              FadeInOffset(
                delayInMilisecond: 250,
                offset: Offset(0, 10),
                child: TextBinggrae('행운 번호 기록'),
              ),
              Space(15),
              FadeInOffset(
                delayInMilisecond: 500,
                offset: Offset(0, 10),
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    thickness: 1,
                    height: 1,
                    color: Color(0xffcccccc),
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.125,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          LottoPickWidget(
                            _luckyNums.length > 0 ? _luckyNums[index + 1] : [],
                            onlyPicks: true,
                            color: Colors.transparent,
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: _luckyNums.length - 1,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> generateLuckyNumbers() async {
    generateNumbers();
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
    _luckyNums.forEach((element) {
      saveList.add(element.map((e) => e.toString()).toList().join(','));
    });
    NetworkUtil().preference.setStringList('lucky', saveList);
  }
}

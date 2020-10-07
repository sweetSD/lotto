import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lotto/widgets/basescreen.dart';
import 'package:lotto/widgets/const.dart';
import 'package:lotto/widgets/dialogs.dart';
import 'package:lotto/widgets/text.dart';
import 'package:lotto/widgets/widgets.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Pair<K, V> {
  K key;
  V value;

  Pair(K key, V value) {
    this.key = key;
    this.value = value;
  }
}

class AnalyzePage extends StatefulWidget {

  List<List<int>> ball;

  AnalyzePage(this.ball, {Key key}) : super(key: key);

  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {

  List<Pair<int, int>> _analyzedBallCounts = List<Pair<int, int>>(45);
  Map<int, int> a;

  int _totalBallCount = 0;

  int _maxCount = 0;

  bool _isSortByNumber = true;

  @override
  void initState() {
    for(int i = 0; i < _analyzedBallCounts.length; i++) _analyzedBallCounts[i] = Pair(i, 0);
    for(int i = 0; i < widget.ball.length; i++) {
      for(int j = 0; j < widget.ball[i].length; j++) {
        _analyzedBallCounts[widget.ball[i][j] - 1].value++;
        if(_analyzedBallCounts[widget.ball[i][j] - 1].value > _maxCount) _maxCount = _analyzedBallCounts[widget.ball[i][j] - 1].value;
        _totalBallCount++;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '당첨 번호 분석',
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.sort, color: Colors.black,),
          onPressed: () {
            buildDialog(context, 
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  color: Colors.transparent,
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSortByNumber = true;
                            _analyzedBallCounts.sort((a, b) => (a?.key ?? 0).compareTo(b?.key ?? 0));
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          color: Colors.white, 
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if(_isSortByNumber) Icon(Icons.arrow_right),
                              TextBinggrae('번호순 정렬')
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSortByNumber = false;
                            _analyzedBallCounts.sort((a, b) => (a?.value ?? 0).compareTo(b?.value ?? 0));
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          color: Colors.white, 
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if(!_isSortByNumber) Icon(Icons.arrow_right),
                              TextBinggrae('당첨순 정렬')
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            )
            ..show();
          },
        ),
      ],
      body: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.1,
            decoration: roundBoxDecoration(),
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                LottoBall(_analyzedBallCounts[index].key + 1),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width * 0.7,
                      lineHeight: 14.0,
                      backgroundColor: Colors.grey,
                      progressColor: Colors.blue,
                      percent: (_analyzedBallCounts[index]?.value ?? 0) / _totalBallCount,
                      animation: true,
                      animationDuration: 1000,
                    ),
                    Space(5),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          TextBinggrae('${(_analyzedBallCounts[index]?.value ?? 0)}', size: 9,),
                          TextBinggrae('$_totalBallCount', size: 9,),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        itemCount: _analyzedBallCounts.length,
      ),
    );
  }
}
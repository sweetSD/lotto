import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lotto/animation/fade.dart';
import 'package:lotto/network/network.dart';
import 'package:lotto/screens/main.dart';
import 'package:lotto/widgets/basescreen.dart';
import 'package:lotto/widgets/const.dart';
import 'package:lotto/widgets/dialogs.dart';
import 'package:lotto/widgets/text.dart';
import 'package:lotto/widgets/widgets.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:async/async.dart';

class Pair<K, V> {
  K key;
  V value;

  Pair(K key, V value) {
    this.key = key;
    this.value = value;
  }
}

class AnalyzePage extends StatefulWidget {

  final List<DateTime> drawDates;
  final List<List<int>> luckyBalls;

  AnalyzePage({Key key, this.drawDates, this.luckyBalls}) : super(key: key);

  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {

  AsyncMemoizer<List<Pair<int, int>>> _asyncMemoizer = AsyncMemoizer<List<Pair<int, int>>>();
  List<Pair<int, int>> _lottoBallStats = List<Pair<int, int>>();
  int _maxCount = 0;
  bool _isSortByNumber = true;

  DateTime _selectedStartDate;
  DateTime _selectedEndDate;
  bool _inclusiveBonus = true;

  @override
  void initState() {
    super.initState();
    if(widget.luckyBalls == null) {
      _selectedStartDate = widget.drawDates.last;
      _selectedEndDate = widget.drawDates.first;
    }
  }

  Future<List<Pair<int, int>>> getLottoStat() async {
    return _asyncMemoizer.runOnce(() async {
      _lottoBallStats.clear();
      for(int i = 0; i < 45; i++) _lottoBallStats.add(Pair<int, int>(i + 1, 0));

      if(widget.luckyBalls == null) {
          var result = await NetworkUtil().getLottoBallStat(sttDrwNo: calculateDrawNum(_selectedStartDate), edDrwNo: calculateDrawNum(_selectedEndDate), srchType: _inclusiveBonus ? 1 : 0);
          for(int i = 0; i < result.length; i++) {
            if(_maxCount < result[i]) _maxCount = result[i];
            _lottoBallStats[i].value = result[i];
          }

      } else {
        for(int i = 0; i < widget.luckyBalls.length; i++) {
          for(int j = 0; j < widget.luckyBalls[i].length; j++) {
            _lottoBallStats[widget.luckyBalls[i][j]].value++;
            if(_maxCount < _lottoBallStats[widget.luckyBalls[i][j]].value) _maxCount = _lottoBallStats[widget.luckyBalls[i][j]].value;
          }
        }
      }
      return _lottoBallStats;
    });
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
      body: FutureBuilder<List<Pair<int, int>>>(
        future: getLottoStat(),
        builder: (context, snapshot) {
          return Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  if(widget.luckyBalls == null) ... [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                showSelectDrawPopup((dateTime) {
                                  setState(() {
                                    if (validateDateTime(dateTime, _selectedEndDate)) { _selectedStartDate = dateTime; _asyncMemoizer = AsyncMemoizer<List<Pair<int, int>>>(); }
                                    else Fluttertoast.showToast(msg: '시작 회차는 끝 회차보다 낮아야합니다.');
                                    Navigator.pop(context);
                                  });
                                }, reversed: true);
                              },
                              child: Container(
                                height: 30,
                                margin: EdgeInsets.symmetric(horizontal: 6),
                                alignment: Alignment.center,
                                decoration: roundBoxDecoration(),
                                child: TextBinggrae('${calculateDrawNum(_selectedStartDate)}회 ~'),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                showSelectDrawPopup((dateTime) {
                                  setState(() {
                                    if (validateDateTime(_selectedStartDate, dateTime)) { _selectedEndDate = dateTime; _asyncMemoizer = AsyncMemoizer<List<Pair<int, int>>>(); }
                                    else Fluttertoast.showToast(msg: '시작 회차는 끝 회차보다 낮아야합니다.');
                                    Navigator.pop(context);
                                  });
                                });
                              },
                              child: Container(
                                height: 30,
                                margin: EdgeInsets.symmetric(horizontal: 6),
                                alignment: Alignment.center,
                                decoration: roundBoxDecoration(),
                                child: TextBinggrae('~ ${calculateDrawNum(_selectedEndDate)}회'),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _inclusiveBonus = !_inclusiveBonus;
                                  _asyncMemoizer = AsyncMemoizer<List<Pair<int, int>>>();
                                });
                              },
                              child: Container(
                                height: 30,
                                margin: EdgeInsets.symmetric(horizontal: 6),
                                decoration: roundBoxDecoration(),
                                alignment: Alignment.center,
                                child: TextBinggrae(_inclusiveBonus ? '보너스 포함' : '보너스 미포함'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  getAnalyzedData(snapshot),
                ],
              ),
            ),
          );
          
        },
      ),
    );
  }

  Widget getAnalyzedData(AsyncSnapshot<List<Pair<int, int>>> snapshot) {
    if(snapshot.hasData) {
      var data = snapshot.data;
      if (_isSortByNumber) {
        data.sort((a, b) => a.key.compareTo(b.key));
      } else {
        data.sort((a, b) => b.value.compareTo(a.value));
      }

      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return FadeInOffset(
            delayInMilisecond: index * 25,
            offset: Offset(0, 50),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.1,
              decoration: roundBoxDecoration(),
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  LottoBall(data[index].key),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width * 0.7,
                        lineHeight: 14.0,
                        backgroundColor: Colors.grey,
                        progressColor: Colors.blue,
                        percent: (data[index]?.value ?? 0) / _maxCount,
                        animation: true,
                        animationDuration: 1000,
                      ),
                      Space(5),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            TextBinggrae('${(data[index]?.value ?? 0)}', size: 9,),
                            TextBinggrae('$_maxCount', size: 9,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: data.length,
      );
    } else if (snapshot.hasError) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 200,
        alignment: Alignment.center,
        child: TextBinggrae('데이터를 불러오는 중 오류가 발생했습니다. :('),
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 200,
        alignment: Alignment.center,
        child: TextBinggrae('데이터를 불러오고 있습니다. :)'),
      );
    }
  }

  bool validateDateTime(DateTime start, DateTime end) => start.isBefore(end);

  void showSelectDrawPopup(Function(DateTime) callback, {bool reversed = false}) {
    buildDialog(context, 
      ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          color: Colors.transparent,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              if(reversed) index = (widget.drawDates.length - 1) - index;
              return GestureDetector(
                onTap: () {
                  callback(widget.drawDates[index]);
                },
                child: Container(
                  color: index % 2 == 0 ? Colors.white : Colors.grey[200], 
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextBinggrae('${calculateDrawNum(widget.drawDates[index])}회')
                    ],
                  ),
                ),
              );
            },
            itemCount: widget.drawDates.length,
          ),
        ),
      )
    )
    ..show();
  }
}
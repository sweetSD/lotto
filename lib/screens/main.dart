import 'dart:async';
import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:intl/intl.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotto/const.dart';
import 'package:lotto/network/lotto.dart';
import 'package:lotto/network/network.dart';
import 'package:lotto/screens/analyze.dart';
import 'package:lotto/screens/horoscope.dart';
import 'package:lotto/screens/lotto.dart';
import 'package:lotto/screens/lucky.dart';
import 'package:lotto/screens/map.dart';
import 'package:lotto/screens/picker.dart';
import 'package:lotto/screens/store.dart';
import 'package:lotto/widgets/basescreen.dart';
import 'package:lotto/widgets/const.dart';
import 'package:lotto/widgets/dialogs.dart';
import 'package:lotto/widgets/lotto.dart';
import 'package:lotto/widgets/text.dart';
import 'package:lotto/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:qrscan/qrscan.dart' as scanner;

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['lotto', '로또', '대박', '인생', '한방'],
  testDevices: <String>[],
);

BannerAd bannerAd = BannerAd(
  adUnitId: BannerAd.testAdUnitId,
  size: AdSize.banner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);

// 직접적으로 접근하지마세요. getInterstitialAd() 함수를 통해서 접근하세요.
InterstitialAd _interstitialAd;
Function(MobileAdEvent) interstitialAdCallbacks;

InterstitialAd getInterstitialAd() {
  if(_interstitialAd == null) {
    _interstitialAd = InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.failedToLoad) {
          _interstitialAd.load();
        } else if (event == MobileAdEvent.closed) {
          _interstitialAd.dispose();
          _interstitialAd = null;
        }
        if(interstitialAdCallbacks != null) interstitialAdCallbacks(event);
        print("InterstitialAd event is $event");
      },
    );
  }
  return _interstitialAd;
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final _imagePicker = ImagePicker();

  int _curDrawNum = 1;
  List<DateTime> _drawDates = [];

  ScrollController _dateScrollController = ScrollController();
  double _dateScrollPosition = 0;

  AsyncMemoizer<Lotto> _asyncMemoizer = AsyncMemoizer<Lotto>();

  @override
  void initState() {
    _curDrawNum = calculateLatestDrawNum();

    for(int i = 0; i < _curDrawNum; i++) {
      _drawDates.add(DateTime(2002, 12, 7, 20, 50, 0).add(Duration(days: i * 7)));
    }

    _drawDates = _drawDates.reversed.toList();

    FirebaseAdMob.instance.initialize(
        appId: Platform.isIOS
            ? admobiOSTestAppID
            : admobAndroidTestAppID).then((value) {
              if(value)
                print('firebase admob initialize success.');
              else
                print('firebase admob initialize failed.');
            });
    bannerAd..load()..show();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final qrButton = IconButton(
      icon: Icon(FontAwesomeIcons.qrcode),
      color: Colors.black,
      onPressed: () async {
        buildDialog(context,
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: roundBoxDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(FontAwesomeIcons.camera),
                      Space(10),
                      TextBinggrae('QR코드 촬영하기')
                    ],
                  ),
                  onTap: () async {
                    var status = await Permission.camera.status;
                    if(status != PermissionStatus.granted && !(await Permission.camera.request().isGranted)) {
                      Fluttertoast.showToast(msg: 'QR코드 스캔에 카메라 권한이 필요합니다.');
                      return;
                    }
                    Navigator.pop(context);
                    final scanResult = await scanner.scan();
                    Fluttertoast.showToast(msg: scanResult);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LottoQRResultPage(scanResult)));
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.storage),
                      Space(10),
                      TextBinggrae('저장된 사진에서 불러오기')
                    ],
                  ),
                  onTap: () async {
                    var status = await Permission.storage.status;
                    if(status != PermissionStatus.granted && !(await Permission.storage.request().isGranted)) {
                      Fluttertoast.showToast(msg: 'QR코드 스캔에 저장소 권한이 필요합니다.');
                      return;
                    }
                    final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);
                    Navigator.pop(context);
                    if(pickedFile != null) {
                      try {
                        print(pickedFile?.path);
                        // 사진에서 QR코드 인식이 안될 경우 아래의 로직이 실행되지 않습니다. (???????)
                        var timer = Timer.periodic(Duration(seconds: 1), (timer) { 
                          timer.cancel();
                          Fluttertoast.showToast(msg: '해당 이미지에서 QR 코드를 인식할 수 없습니다.');
                        });
                        var scanResult = await scanner.scanPath(pickedFile.path);
                        print(scanResult);
                        if(timer != null) timer.cancel();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LottoQRResultPage(scanResult)));
                      } catch(e) {
                        print('!' + e);
                      }
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => LottoQRResultPage('https://m.dhlottery.co.kr/qr.do?method=winQr&v=0813q112730313843q101824252728q011314242543q030619214044q1430353843440000001677')));
                    }
                  },
                ),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.fact_check_rounded),
                      Space(10),
                      TextBinggrae('직접 입력하기')
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NumberPickPage(_drawDates),));
                  },
                ),
              ],
            ),
          )
        ).show();
      },
    );

    final appbar = AppBar(
      title: TextBinggrae('인생로또', size: 20,),
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(FontAwesomeIcons.store, color: Colors.black,),
        onPressed: () async {
          var status = await Permission.location.status;
          if(status != PermissionStatus.granted && !(await Permission.location.request().isGranted)) {
            Fluttertoast.showToast(msg: '현재 위치 파악을 위해 위치 권한이 필요합니다.');
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (context) => MapSample()));
        },
      ),
      actions: <Widget>[
        qrButton
      ],
    );

    return FutureBuilder<Lotto>(
      future: getLotto(_curDrawNum),
      builder: (context, snapshot) {
        return BaseScreen(
          appBar: appbar,
          body: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shrinkWrap: true,
            children: <Widget>[
              if(snapshot.hasData) ... [
                AnimatedOpacity(opacity: 1, duration: Duration(milliseconds: 500), child: LottoWinResultWidget(snapshot.data),),
              ],
              Space(10),
              if(snapshot.hasData) ... [
                AnimatedOpacity(
                  opacity: 1, 
                  duration: Duration(milliseconds: 500),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: roundBoxDecoration(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(child: TextBinggrae('총 판매금액', color: Colors.grey, align: TextAlign.left,),),
                            Expanded(child: TextBinggrae(currencyFormat.format(snapshot.data.totalSellAmount) + '원', align: TextAlign.right,),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(child: TextBinggrae('1등 당첨금액', color: Colors.grey, align: TextAlign.left,),),
                            Expanded(child: TextBinggrae(currencyFormat.format(snapshot.data.winnerAmount) + '원', align: TextAlign.right,),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(child: TextBinggrae('1등 당첨자', color: Colors.grey, align: TextAlign.left,),),
                            Expanded(child: TextBinggrae(currencyFormat.format(snapshot.data.winnerCount) + '명', align: TextAlign.right,),),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Space(10),
              ],
              InkWell(
                onTap: () {
                  _dateScrollController = ScrollController(initialScrollOffset: _dateScrollPosition);
                  _dateScrollController.addListener(() {
                    _dateScrollPosition = _dateScrollController.offset;
                  });
                  showSelectDrawPopup();
                },
                child: Container(
                  height: 45,
                  alignment: Alignment.center,
                  decoration: roundBoxDecoration().copyWith(color: Colors.grey[200]),
                  child: TextBinggrae('회차 선택'),
                ),
              ),
              Space(10),
              InkWell(
                onTap: () async {
                  List<List<int>> lottoes = List<List<int>>();
                  final pd = ProgressDialog(context, type: ProgressDialogType.Download, isDismissible: false);
                  pd.style(
                    message: '회차 정보를 불러오고 있습니다.\n처음일 경우 약간의 시간이 소요됩니다.',
                    messageTextStyle: TextStyle(fontFamily: 'Binggrae', fontSize: 12),
                  );
                  await pd.show();
                  int count = calculateDrawNum(DateTime.now());
                  for(int i = 0; i < count; i++) {
                    pd.update(
                      message: '${i + 1}회차 정보를 불러오고 있습니다.\n처음일 경우 약간의 시간이 소요됩니다.',
                      messageTextStyle: TextStyle(fontFamily: 'Binggrae', fontSize: 12),
                      progress: i.toDouble(),
                      maxProgress: count.toDouble(),
                    );
                    try {
                      var lotto = await NetworkUtil().getLottoNumber(i + 1);
                      lottoes.add([lotto.drawNo1, lotto.drawNo2, lotto.drawNo3, lotto.drawNo4, lotto.drawNo5, lotto.drawNo6]);
                    } catch(e) {
                      print(e);
                      Fluttertoast.showToast(msg: '회차 정보를 불러오는 중 에러가 발생했습니다.');
                      return;
                    }
                  }
                  await pd.hide();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyzePage(lottoes),));
                },
                child: Container(
                  height: 45,
                  alignment: Alignment.center,
                  decoration: roundBoxDecoration().copyWith(color: Colors.grey[200]),
                  child: TextBinggrae('당첨 번호 통계 확인'),
                ),
              ),
              Divider(height: 25, thickness: 1, color: Colors.grey[200],),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LuckyBallPage(),));
                },
                child: Container(
                  height: 45,
                  alignment: Alignment.center,
                  decoration: roundBoxDecoration().copyWith(color: Colors.grey[200]),
                  child: TextBinggrae('행운 번호 확인'),
                ),
              ),
              // Space(10),
              // InkWell(
              //   onTap: () {
              //     Navigator.push(context, MaterialPageRoute(builder: (context) => HoroscopePage(),));
              //   },
              //   child: Container(
              //     height: 75,
              //     alignment: Alignment.center,
              //     decoration: roundBoxDecoration().copyWith(color: Colors.grey[200]),
              //     child: TextBinggrae('띠별 운세 확인'),
              //   ),
              // ),
              Space(50),
            ],
          ),
        );
      },
    );
  }

  Future<Lotto> getLotto(int drawNum) {
    return _asyncMemoizer.runOnce(() async {
      var prefs = (await NetworkUtil().preferenceAsync);
      if(!prefs.containsKey('firstSync')) {
        await NetworkUtil().syncLottoResultsFromFirebase();
        await prefs.setBool('firstSync', true);
      }
      return await NetworkUtil().getLottoNumber(drawNum);
    });
  }

  void showSelectDrawPopup() {
    buildDialog(context, 
      ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          color: Colors.transparent,
          child: ListView.builder(
            controller: _dateScrollController,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _curDrawNum = _drawDates.length - index;
                    _asyncMemoizer = AsyncMemoizer<Lotto>();
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  color: index % 2 == 0 ? Colors.white : Colors.grey[200], 
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if(_drawDates.length - index == _curDrawNum) Icon(Icons.arrow_right),
                      TextBinggrae('${calculateDrawNum(_drawDates[index])}회 (${DateFormat('yyyy-MM-dd').format(_drawDates[index])})')
                    ],
                  ),
                ),
              );
            },
            itemCount: _drawDates.length,
          ),
        ),
      )
    )
    ..show();
  }
}

int calculateLatestDrawNum() {
  return calculateDrawNum(DateTime.now());
}

int calculateDrawNum(DateTime date) {
  DateTime beginDateTime = DateTime(2002, 12, 7, 20, 50, 0);

  Duration diff = date.difference(beginDateTime);
  int drawNum = ((diff.inDays / 7) + 1).toInt();
  return drawNum;
}
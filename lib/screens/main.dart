import 'dart:async';
import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotto/animation/fade.dart';
import 'package:lotto/const.dart';
import 'package:lotto/network/lotto.dart';
import 'package:lotto/network/network.dart';
import 'package:lotto/screens/analyze.dart';
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
  //adUnitId: BannerAd.testAdUnitId,
  adUnitId: admobBannerID,
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
      //adUnitId: InterstitialAd.testAdUnitId,
      adUnitId: admobInterstitialID,
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

DateTime beginDateTime = DateTime(2002, 12, 7, 20, 55, 0);

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
      _drawDates.add(beginDateTime.add(Duration(days: i * 7)));
    }

    _drawDates = _drawDates.reversed.toList();

    FirebaseAdMob.instance.initialize(
        appId: Platform.isIOS
            ? admobiOSTestAppID
            : admobAppID).then((value) {
              if(value)
                print('firebase admob initialize success.');
              else
                print('firebase admob initialize failed.');
            });
    //bannerAd..load()..show();

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
                    //Fluttertoast.showToast(msg: scanResult);
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextBinggrae('K - ', size: 25, color: Color(0xffffA401), height: 1.1,),
          TextBinggrae('로또', size: 25, color: Color(0xff00B0F0), height: 1.1,),
        ],
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(FontAwesomeIcons.store, color: Colors.black,),
        onPressed: () async {
          buildDialog(context,
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: roundBoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.near_me_rounded),
                        Space(10),
                        TextBinggrae('주변 판매점 찾기')
                      ],
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      var status = await Permission.location.status;
                      if(status != PermissionStatus.granted && !(await Permission.location.request().isGranted)) {
                        Fluttertoast.showToast(msg: '현재 위치 파악을 위해 위치 권한이 필요합니다.');
                        return;
                      }
                      Fluttertoast.showToast(msg: '편의점의 경우 로또 판매가 확실하지 않을 수 있습니다.');
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NearStoreMapPage()));
                    },
                  ),
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(FontAwesomeIcons.trophy),
                        Space(10),
                        TextBinggrae('당첨 판매점 찾기')
                      ],
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LottoRankStorePage()));
                    },
                  ),
                ],
              ),
            )
          ).show();
        },
      ),
      actions: <Widget>[
        qrButton
      ],
    );

    return FutureBuilder<Lotto>(
      future: getLotto(_curDrawNum),
      builder: (context, snapshot) {
        var data = snapshot.data;
        return BaseScreen(
          appBar: appbar,
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              children: <Widget> [
                Space(10),
                AnimatedOpacity(opacity: snapshot.hasData ? 1 : 0, duration: Duration(milliseconds: 750), child: LottoWinResultWidget(snapshot.hasData ? data : Lotto(
                  '', 0, beginDateTime, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                )),),
                Space(10),
                AnimatedOpacity(
                  opacity: snapshot.hasData ? 1 : 0, 
                  duration: Duration(milliseconds: 750),
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
                            Expanded(child: TextBinggrae((snapshot.hasData && data.totalSellAmount > 0) ? currencyFormat.format(data.totalSellAmount) + '원' : '집계중', align: TextAlign.right,),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(child: TextBinggrae('1등 당첨금액', color: Colors.grey, align: TextAlign.left,),),
                            Expanded(child: TextBinggrae((snapshot.hasData && data.totalSellAmount > 0) ? currencyFormat.format(data.winnerAmount) + '원' : '집계중', align: TextAlign.right,),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(child: TextBinggrae('1등 당첨자', color: Colors.grey, align: TextAlign.left,),),
                            Expanded(child: TextBinggrae((snapshot.hasData && data.totalSellAmount > 0) ? currencyFormat.format(data.winnerCount) + '명' : '집계중', align: TextAlign.right,),),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Space(10),
                FadeInOffset(
                  delayInMilisecond: 0,
                  offset: Offset(0, 50),
                  child: InkWell(
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
                ),
                Space(10),
                FadeInOffset(
                  delayInMilisecond: 150,
                  offset: Offset(0, 50),
                  child: InkWell(
                    onTap: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyzePage(drawDates: _drawDates,),));
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      decoration: roundBoxDecoration().copyWith(color: Colors.grey[200]),
                      child: TextBinggrae('당첨 번호 통계 확인'),
                    ),
                  ),
                ),
                FadeInOffset(
                  delayInMilisecond: 300,
                  offset: Offset(0, 50),
                  child: Divider(height: 25, thickness: 1, color: Colors.grey[200],),
                ),
                FadeInOffset(
                  delayInMilisecond: 450,
                  offset: Offset(0, 50),
                  child: InkWell(
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
                ),
                Space(10),
                FadeInOffset(
                  delayInMilisecond: 600,
                  offset: Offset(0, 50),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => QRResultPage(),));
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      decoration: roundBoxDecoration().copyWith(color: Colors.grey[200]),
                      child: TextBinggrae('QR코드 기록'),
                    ),
                  ),
                ),
                // Space(10),
                // InkWell(
                //   onTap: () {

                //   },
                //   child: Container(
                //     height: 45,
                //     alignment: Alignment.center,
                //     decoration: roundBoxDecoration().copyWith(color: Colors.cyan[50]),
                //     child: TextBinggrae('개발자에게 로또 후원하기'),
                //   ),
                // ),
                Space(60),
              ],
            )
          ),
        );
      },
    );
  }

  Future<Lotto> getLotto(int drawNum) {
    return _asyncMemoizer.runOnce(() async {
      Future.delayed(Duration.zero, () async {
        var prefs = (await NetworkUtil().preferenceAsync);
        if(!prefs.containsKey('firstSync')) {
          await NetworkUtil().syncLottoResultsFromFirebase();
          await prefs.setBool('firstSync', true);
        }
      });
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
            physics: ClampingScrollPhysics(),
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
  Duration diff = date.difference(beginDateTime);
  int drawNum = ((diff.inDays / 7) + 1).toInt();
  return drawNum;
}

DateTime calculateDateTime(int drawNum) {
  return beginDateTime.add(Duration(days: ((drawNum - 1) * 7).toInt()));
}
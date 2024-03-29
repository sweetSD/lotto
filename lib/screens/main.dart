import 'dart:async';

import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotto/animation/fade.dart';
import 'package:lotto/network/lotto.dart';
import 'package:lotto/network/network.dart';
import 'package:lotto/screens/analyze.dart';
import 'package:lotto/screens/lotto.dart';
import 'package:lotto/screens/lucky.dart';
import 'package:lotto/screens/map.dart';
import 'package:lotto/screens/picker.dart';
import 'package:lotto/widgets/basescreen.dart';
import 'package:lotto/widgets/const.dart';
import 'package:lotto/widgets/dialogs.dart';
import 'package:lotto/widgets/lotto.dart';
import 'package:lotto/widgets/text.dart';
import 'package:lotto/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';

// 로또가 처음으로 시작한 날짜.
DateTime beginDateTime = DateTime(2002, 12, 7, 20, 55, 0);

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _imagePicker = ImagePicker();

  int? _curDrawNum = 1;
  List<DateTime> _drawDates = [];

  ScrollController _dateScrollController = ScrollController();
  double _dateScrollPosition = 0;

  AsyncMemoizer<Lotto> _asyncMemoizer = AsyncMemoizer<Lotto>();

  @override
  void initState() {
    _curDrawNum = calculateLatestDrawNum();

    for (int i = 0; i < _curDrawNum!; i++) {
      _drawDates.add(beginDateTime.add(Duration(days: i * 7)));
    }

    debugPrint(_curDrawNum.toString());

    Future.delayed(Duration.zero, () async {
      Lotto? lotto;
      int tempDrawNum = _curDrawNum!;

      while (lotto == null || lotto.result == "fail") {
        lotto = await NetworkUtil().getLottoNumber(tempDrawNum--);
      }

      _curDrawNum = lotto.drawNumber as int?;
    });

    _drawDates = _drawDates.reversed.toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final qrButton = IconButton(
      icon: const Icon(FontAwesomeIcons.qrcode),
      color: Colors.black,
      onPressed: () async {
        buildDialog(
            context,
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: roundBoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ListTile(
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(FontAwesomeIcons.camera),
                        Space(10),
                        LottoText('QR코드 촬영하기')
                      ],
                    ),
                    onTap: () async {
                      var status = await Permission.camera.status;
                      if (status != PermissionStatus.granted &&
                          !(await Permission.camera.request().isGranted)) {
                        Fluttertoast.showToast(msg: 'QR코드 스캔에 카메라 권한이 필요합니다.');
                        return;
                      }
                      Navigator.pop(context);
                      final scanResult = await scanner.scan();
                      //Fluttertoast.showToast(msg: scanResult);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LottoQRResultPage(scanResult)));
                    },
                  ),
                  ListTile(
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.storage),
                        Space(10),
                        LottoText('저장된 사진에서 불러오기')
                      ],
                    ),
                    onTap: () async {
                      var status = await Permission.storage.status;
                      if (status != PermissionStatus.granted &&
                          !(await Permission.storage.request().isGranted)) {
                        Fluttertoast.showToast(msg: 'QR코드 스캔에 저장소 권한이 필요합니다.');
                        return;
                      }
                      final pickedFile = await _imagePicker.getImage(
                          source: ImageSource.gallery);
                      Navigator.pop(context);
                      if (pickedFile != null) {
                        try {
                          debugPrint(pickedFile.path);
                          // 사진에서 QR코드 인식이 안될 경우 아래의 로직이 실행되지 않습니다. (???????)
                          var timer =
                              Timer.periodic(const Duration(seconds: 1), (timer) {
                            timer.cancel();
                            Fluttertoast.showToast(
                                msg:
                                    '해당 이미지에서 QR 코드를 인식할 수 없습니다. (인식률이 낮을 수 있습니다.)');
                          });
                          var scanResult =
                              await scanner.scanPath(pickedFile.path);
                          debugPrint(scanResult);
                          timer.cancel();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LottoQRResultPage(scanResult)));
                        } catch (e) {
                          debugPrint('!$e');
                        }
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => LottoQRResultPage('https://m.dhlottery.co.kr/qr.do?method=winQr&v=0813q112730313843q101824252728q011314242543q030619214044q1430353843440000001677')));
                      }
                    },
                  ),
                  ListTile(
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.fact_check_rounded),
                        Space(10),
                        LottoText('직접 입력하기')
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NumberPickPage(_drawDates),
                          ));
                    },
                  ),
                ],
              ),
            ));
      },
    );

    final appbar = AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 65,
            child: Image.asset("assets/images/new_icon_512x512_clear.png"),
          )
        ],
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          FontAwesomeIcons.store,
          color: Colors.black,
        ),
        onPressed: () async {
          buildDialog(
              context,
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: roundBoxDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ListTile(
                      title: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.near_me_rounded),
                          Space(10),
                          LottoText('주변 판매점 찾기')
                        ],
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        var status = await Permission.location.status;
                        if (status != PermissionStatus.granted &&
                            !(await Permission.location.request().isGranted)) {
                          Fluttertoast.showToast(
                              msg: '현재 위치 파악을 위해 위치 권한이 필요합니다.');
                          return;
                        }
                        Fluttertoast.showToast(
                            msg: '편의점의 경우 로또 판매가 확실하지 않을 수 있습니다.');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const NearStoreMapPage()));
                      },
                    ),
                  ],
                ),
              ));
        },
      ),
      actions: <Widget>[qrButton],
    );

    return FutureBuilder<Lotto>(
      future: getLotto(_curDrawNum!),
      builder: (context, snapshot) {
        var data = snapshot.data;
        if (snapshot.hasError) {
          return BaseScreen(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 65,
                    child:
                        Image.asset("assets/images/new_icon_512x512_clear.png"),
                  )
                ],
              ),
              backgroundColor: Colors.white,
              centerTitle: true,
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: const LottoText("오류가 발생하였습니다.\n잠시후 다시 시도해주세요."),
            ),
          );
        }

        return BaseScreen(
          appBar: appbar,
          body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                children: <Widget>[
                  const Space(10),
                  if (snapshot.hasData) ...[
                    AnimatedOpacity(
                      opacity: snapshot.hasData ? 1 : 0,
                      duration: const Duration(milliseconds: 750),
                      child: LottoWinResultWidget(snapshot.hasData
                          ? data
                          : Lotto('', 0, beginDateTime, 0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0)),
                    ),
                    const Space(10),
                    AnimatedOpacity(
                      opacity: snapshot.hasData ? 1 : 0,
                      duration: const Duration(milliseconds: 750),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: roundBoxDecoration(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                const Expanded(
                                  child: LottoText(
                                    '총 판매금액',
                                    color: Colors.grey,
                                    align: TextAlign.left,
                                  ),
                                ),
                                Expanded(
                                  child: LottoText(
                                    (snapshot.hasData &&
                                            data!.totalSellAmount! > 0)
                                        ? '${currencyFormat
                                                .format(data.totalSellAmount)}원'
                                        : '집계중',
                                    align: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                const Expanded(
                                  child: LottoText(
                                    '1등 당첨금액',
                                    color: Colors.grey,
                                    align: TextAlign.left,
                                  ),
                                ),
                                Expanded(
                                  child: LottoText(
                                    (snapshot.hasData &&
                                            data!.totalSellAmount! > 0)
                                        ? '${currencyFormat
                                                .format(data.winnerAmount)}원'
                                        : '집계중',
                                    align: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                const Expanded(
                                  child: LottoText(
                                    '1등 당첨자',
                                    color: Colors.grey,
                                    align: TextAlign.left,
                                  ),
                                ),
                                Expanded(
                                  child: LottoText(
                                    (snapshot.hasData &&
                                            data!.totalSellAmount! > 0)
                                        ? '${currencyFormat
                                                .format(data.winnerCount)}명'
                                        : '집계중',
                                    align: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          Space(30),
                          LottoText('최근 당첨 번호를 로딩중입니다.\n잠시만 기다려주세요.')
                        ],
                      ),
                    ),
                  ],
                  const Space(10),
                  FadeInOffset(
                    delayInMilisecond: 0,
                    offset: const Offset(0, 50),
                    child: InkWell(
                      onTap: () async {
                        _dateScrollController = ScrollController(
                            initialScrollOffset: _dateScrollPosition);
                        _dateScrollController.addListener(() {
                          _dateScrollPosition = _dateScrollController.offset;
                        });
                        showSelectDrawPopup();
                      },
                      child: Container(
                        height: 45,
                        alignment: Alignment.center,
                        decoration: roundBoxDecoration()
                            .copyWith(color: Colors.grey[200]),
                        child: const LottoText('회차 선택'),
                      ),
                    ),
                  ),
                  const Space(10),
                  FadeInOffset(
                    delayInMilisecond: 150,
                    offset: const Offset(0, 50),
                    child: InkWell(
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnalyzePage(
                                drawDates: _drawDates,
                              ),
                            ));
                      },
                      child: Container(
                        height: 45,
                        alignment: Alignment.center,
                        decoration: roundBoxDecoration()
                            .copyWith(color: Colors.grey[200]),
                        child: const LottoText('당첨 번호 통계 확인'),
                      ),
                    ),
                  ),
                  FadeInOffset(
                    delayInMilisecond: 300,
                    offset: const Offset(0, 50),
                    child: Divider(
                      height: 25,
                      thickness: 1,
                      color: Colors.grey[200],
                    ),
                  ),
                  FadeInOffset(
                    delayInMilisecond: 450,
                    offset: const Offset(0, 50),
                    child: InkWell(
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LuckyBallPage(),
                            ));
                      },
                      child: Container(
                        height: 45,
                        alignment: Alignment.center,
                        decoration: roundBoxDecoration()
                            .copyWith(color: Colors.grey[200]),
                        child: const LottoText('행운 번호 확인'),
                      ),
                    ),
                  ),
                  const Space(10),
                  FadeInOffset(
                    delayInMilisecond: 600,
                    offset: const Offset(0, 50),
                    child: InkWell(
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QRResultPage(),
                            ));
                      },
                      child: Container(
                        height: 45,
                        alignment: Alignment.center,
                        decoration: roundBoxDecoration()
                            .copyWith(color: Colors.grey[200]),
                        child: const LottoText('QR코드 기록'),
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
                  //     child: LottoText('개발자에게 로또 후원하기'),
                  //   ),
                  // ),
                  const Space(60),
                ],
              )),
        );
      },
    );
  }

  Future<Lotto> getLotto(int drawNum) {
    return _asyncMemoizer.runOnce(() async {
      await Future.delayed(Duration.zero, () async {
        var prefs = await NetworkUtil().preferenceAsync as SharedPreferences;
        if (!prefs.containsKey('firstSync')) {
          await NetworkUtil().syncLottoResultsFromFirebase();
          await prefs.setBool('firstSync', true);
        }
      });

      Lotto? lotto;

      while (lotto == null || lotto.result == "fail") {
        lotto = await NetworkUtil().getLottoNumber(drawNum--);
      }
      return lotto;
    });
  }

  void showSelectDrawPopup() {
    buildDialog(
        context,
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.transparent,
            child: ListView.builder(
              controller: _dateScrollController,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    var lotto = await NetworkUtil()
                        .getLottoNumber(_drawDates.length - index);
                    if (lotto.result == "fail") {
                      Fluttertoast.showToast(
                          msg:
                              "${_drawDates.length - index} 해당 회차의 추첨이 진행되지 않았습니다. 잠시후 다시 시도해주세요.");
                    } else {
                      _asyncMemoizer = AsyncMemoizer<Lotto>();
                      _curDrawNum = _drawDates.length - index;
                    }
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    color: index % 2 == 0 ? Colors.white : Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (_drawDates.length - index == _curDrawNum)
                          const Icon(Icons.arrow_right),
                        LottoText(
                            '${calculateDrawNum(_drawDates[index])}회 (${DateFormat('yyyy-MM-dd').format(_drawDates[index])})')
                      ],
                    ),
                  ),
                );
              },
              itemCount: _drawDates.length,
            ),
          ),
        ));
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

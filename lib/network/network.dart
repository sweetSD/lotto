import 'dart:convert' as convert;
import 'package:html/dom.dart' as dom;
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:lotto/const.dart';
import 'package:lotto/encode.dart';
import 'package:lotto/network/lotto.dart';
import 'package:lotto/network/place.dart';
import 'package:lotto/screens/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkUtil {
  static final String _baseUrl = "https://www.dhlottery.co.kr";
  static String get baseUrl => _baseUrl;

  static final NetworkUtil _instance = NetworkUtil._internal();
  NetworkUtil._internal() {}
  factory NetworkUtil() => _instance;

  SharedPreferences? _preferences;
  SharedPreferences? get preference => _preferences;
  Future<SharedPreferences?> get preferenceAsync async => _preferences == null
      ? _preferences = await SharedPreferences.getInstance()
      : _preferences;

  // 주어진 회차 정보에 대한 로또 당첨 번호를 조회합니다.
  Future<Lotto> getLottoNumber(int? drawNo) async {
    String key = 'lotto_$drawNo';
    if (_preferences == null)
      _preferences = await SharedPreferences.getInstance();
    if (_preferences!.containsKey(key)) {
      var lotto =
          Lotto.fromJson(convert.jsonDecode(_preferences!.getString(key)!));
      if (lotto.totalSellAmount != 0) return Future<Lotto>.value(lotto);
    }
    var response = await http.get(
        Uri.parse(_baseUrl + '/common.do?method=getLottoNumber&drwNo=$drawNo'));
    if (response.statusCode == 200) {
      Lotto lotto = Lotto.fromJson(convert.jsonDecode(response.body));
      if (lotto.result == "success") {
        await _preferences!.setString(key, convert.jsonEncode(lotto));
      }
      return Future<Lotto>.value(lotto);
    }
    return Future<Lotto>.error(response);
  }

  // 주어진 회차 정보에 대한 로또 당첨 번호를 조회합니다. (V2: 1등 당첨 자동, 수동, 반자동 추가)
  Future<Lotto> getLottoNumberV2(Lotto lotto) async {
    String key = 'lotto_${lotto.drawNumber}';
    if (_preferences == null)
      _preferences = await SharedPreferences.getInstance();
    if (_preferences!.containsKey(key)) {
      return Future<Lotto>.value(
          Lotto.fromJson(convert.jsonDecode(_preferences!.getString(key)!)));
    }
    var response = await http.get(Uri.parse(
        _baseUrl + '/gameResult.do?method=byWin&drwNo=${lotto.drawNumber}'));
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);

      var winResult = document
          .getElementsByClassName('tbl_data tbl_data_col')[0]
          .children[3]
          .children[0]
          .children[5];

      for (int i = 1; i < winResult.children.length; i++) {
        var textData = winResult.children[i].text.trim();

        if (textData.startsWith('자동'))
          lotto.winnerAutoCount = int.tryParse(textData.substring(2));
        if (textData.startsWith('수동'))
          lotto.winnerManualCount = int.tryParse(textData.substring(2));
        if (textData.startsWith('반자동'))
          lotto.winnerSemiAutoCount = int.tryParse(textData.substring(3));
      }

      return Future<Lotto>.value(lotto);
    }
    return Future<Lotto>.error(response);
  }

  // 주어진 QR코드 인싱된 웹사이트 링크에서 결과를 파싱합니다.
  Future<LottoQRResult> getLottoQRCodeResult(String url) async {
    try {
      var response =
          await http.get(Uri.parse(url.replaceAll('nlotto', 'dhlottery')));

      if (response.statusCode == 200) {
        dom.Document document = parser.parse(response.body);

        var winnerNumber = document.getElementsByClassName('winner_number')[0];

        String drawNo = winnerNumber.children[0].children[0].text;

        var myNumberList = document
            .getElementsByClassName('list_my_number')[0]
            .children[0]
            .children[0]
            .children[2];

        List<LottoPick> myPicks = [];

        for (int i = 0; i < myNumberList.children.length; i++) {
          List<int> pickNumbers = [];
          for (int j = 0;
              j < myNumberList.children[i].children[2].children.length;
              j++) {
            pickNumbers.add(int.parse(
                myNumberList.children[i].children[2].children[j].text));
          }
          myPicks.add(LottoPick(
              int.tryParse(myNumberList.children[i].children[1].text
                      .replaceAll(RegExp(r'[^0-9]'), '')) ??
                  0,
              pickNumbers));
        }
        print(calculateDrawNum(DateTime.now()));
        print(int.parse(drawNo.substring(2, 2 + drawNo.length - 4)));
        if (calculateDrawNum(DateTime.now()) <
            int.parse(drawNo.substring(2, 2 + drawNo.length - 4))) {
          print('!');
          return Future<LottoQRResult>.value(
              LottoQRResult(null, 0, myPicks, url));
        } else {
          Lotto drawResult = await getLottoNumber(
              int.parse(drawNo.substring(2, 2 + drawNo.length - 4)));

          print('!!');
          var key_clr1 = winnerNumber.children[2].children[0].children[1]
              .getElementsByClassName('key_clr1');
          if (key_clr1.length > 0) {
            String prize = key_clr1[0].text;
            return Future<LottoQRResult>.value(LottoQRResult(
                drawResult,
                int.tryParse(prize.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                myPicks,
                url));
          } else {
            return Future<LottoQRResult>.value(
                LottoQRResult(drawResult, 0, myPicks, url));
          }
        }
      }
    } catch (e) {
      print('error - ' + e.toString());
    }
    return Future<LottoQRResult>.error(Error());
  }

  // 주어진 회차에 당첨자 배출점을 조회합니다.
  //Future<LottoQRResult> getLottoStore(String url) async {}

  Future<void> syncLottoResultsToFirebase() async {
    String json = '[';
    List<String> results = [];
    if (_preferences == null)
      _preferences = await SharedPreferences.getInstance();
    DatabaseReference lottoResultsRef =
        FirebaseDatabase.instance.reference().child('lottoResults');
    for (int i = 0; i < 931; i++) {
      String? result = _preferences!.getString('lotto_${i + 1}');
      if (result != null && result.isNotEmpty) results.add(result);
    }
    json += results.join(',');
    json += ']';
    await lottoResultsRef.set({'results': json});
  }

  Future<void> syncLottoResultsFromFirebase() async {
    DatabaseReference lottoResultsRef =
        FirebaseDatabase.instance.reference().child('lottoResults');
    final snapshot = await lottoResultsRef.once();
    print(snapshot);
    print(snapshot?.key ?? 'key null');
    print(snapshot?.value['results'] ?? 'value null');
    var list = List.from(convert.jsonDecode(snapshot?.value['results']))
        .map((e) => Lotto.fromJson(e))
        .toList();
    for (int i = 0; i < list.length; i++) {
      if (!_preferences!.containsKey('lotto_${list[i].drawNumber}'))
        _preferences!.setString(
            'lotto_${list[i].drawNumber}', convert.jsonEncode(list[i]));
    }
  }

  // 오늘의 띠별 운세 정보를 파싱합니다.
  Future<void> getHoroscope() async {
    try {
      var response = await http.get(
          Uri.parse(
              'https://search.naver.com/search.naver?sm=top_hty&fbm=1&ie=utf8&query=%EB%9D%A0%EB%B3%84+%EC%9A%B4%EC%84%B8'),
          headers: {
            HttpHeaders.contentTypeHeader: 'text/html; charset=euc-kr'
          });
      if (response.statusCode == 200) {
        dom.Document document = parser.parse(response.body);

        var containerList = document.getElementsByClassName('sign_lst')[0];

        for (int i = 0; i < containerList.children.length; i++) {
          var container = containerList.children[i];
          print(container.children[0].children[0].attributes['href']);
          print(
              container.children[0].children[0].children[0].attributes['src']);
          print(container.children[1].children[0].text);
          print(container.children[2].text);
        }
        return Future<void>.value(null);
      }
    } catch (e) {
      print('error - ' + e.toString());
    }
    return Future<void>.error(Error());
  }

  Future<PlaceResponse> getPlaceFromKakaoAPI(
      String query, Position position, int radius,
      {int page = 1}) async {
    try {
      var uri = Uri.https('dapi.kakao.com', '/v2/local/search/keyword.json', {
        'query': query,
        'y': position.latitude.toString(),
        'x': position.longitude.toString(),
        'radius': radius.toString(),
        'page': page.toString()
      });
      var response = await http.get(uri,
          headers: {HttpHeaders.authorizationHeader: 'KakaoAK $kakaoApiKey'});
      if (response.statusCode == 200) {
        Clipboard.setData(ClipboardData(text: response.body));
        var places = List.from(convert.jsonDecode(response.body)['documents'])
            .map((e) => Place.fromJson(e))
            .toList();

        return Future<PlaceResponse>.value(PlaceResponse(places,
            convert.jsonDecode(response.body)['meta']['is_end'] as bool?));
      }
    } catch (e) {
      print('error - ' + e.toString());
    }
    return Future<PlaceResponse>.error(PlaceResponse([], true));
  }

  Future<PlaceResponse> getStoreByLottoSite(String sido, String gugun,
      {int page = 1}) async {
    try {
      var uri =
          Uri.https('dhlottery.co.kr', '/store.do?method=sellerInfo645Result');
      var response = await http.post(uri, headers: {
        HttpHeaders.contentTypeHeader:
            'application/x-www-form-urlencoded; charset=euc-kr',
        HttpHeaders.cacheControlHeader: 'Cache-Control'
      }, body: {
        'nowPage': '$page',
        'rtlrSttus': '001', // 001 영업점 002 폐점
        'searchType': '1',
        'sltSIDO': await UrlEncoder().encode(sido, 'euc-kr'),
        'sltGUGUN': await UrlEncoder().encode(gugun, 'euc-kr'),
      });
      if (response.statusCode == 200) {
        Clipboard.setData(ClipboardData(text: response.body));
        var places = List.from(convert.jsonDecode(response.body)['documents'])
            .map((e) => Place.fromJson(e))
            .toList();

        return Future<PlaceResponse>.value(PlaceResponse(places,
            convert.jsonDecode(response.body)['meta']['is_end'] as bool?));
      }
    } catch (e) {
      print('error - ' + e.toString());
    }
    return Future<PlaceResponse>.error(PlaceResponse([], true));
  }

  Future<List<String>> getGugun(String sido) async {
    try {
      sido = (await UrlEncoder().encode(sido));
      var uri =
          Uri.https('dhlottery.co.kr', '/store.do', {'method': 'searchGUGUN'});
      var response = await http.post(uri, headers: {
        HttpHeaders.cacheControlHeader: 'no-cache',
        HttpHeaders.acceptHeader: 'application/json'
      }, body: {
        'SIDO': sido,
      });
      if (response.statusCode == 200) {
        print(response.body);
        print(await UrlEncoder().decodeByte(response.bodyBytes, 'euc-kr'));
        return Future<List<String>>.value(List<String>.from(convert.jsonDecode(
            await UrlEncoder().decodeByte(response.bodyBytes, 'euc-kr'))));
      }
    } catch (e) {
      print('error - ' + e.toString());
    }
    return Future<List<String>>.error([]);
  }

  // 로또 1등 당첨 판매점을 조회합니다.
  Future<List<LottoStore>> getLottoTopStoreRank(
      [int page = 1, int rank = 1]) async {
    List<LottoStore> result = [];
    try {
      var response = await http.get(Uri.parse(
          'https://dhlottery.co.kr/store.do?method=topStoreRank&rank=$rank&pageGubun=L645&nowPage=$page'));
      if (response.statusCode == 200) {
        dom.Document document = parser
            .parse(await UrlEncoder().decodeByte(response.bodyBytes, 'euc-kr'));

        var listRoot = document
            .getElementsByClassName('tbl_data tbl_data_col')[0]
            .children[3];

        for (int i = 0; i < listRoot.children.length; i++) {
          var store = listRoot.children[i];
          result.add(LottoStore(
              num.tryParse(store.children[0].text),
              store.children[1].text.trim(),
              num.tryParse(store.children[2].text),
              store.children[3].text.trim(),
              num.tryParse(store.children[4].children[0].attributes['onclick']!
                  .trim()
                  .replaceAll("javascript:showMapPage('", '')
                  .replaceAll("'); return false;", ''))));
        }

        return Future<List<LottoStore>>.value(result);
      }
    } catch (e) {
      print('error - ' + e.toString());
    }
    return Future<List<LottoStore>>.error(result);
  }

  // 로또 당첨 번호 통계를 조회합니다. (srchType - 1 : 보너스 포함 / 0 : 보너스 미포함)
  Future<List<int?>> getLottoBallStat(
      {int sttDrwNo = 1, int edDrwNo = 934, int srchType = 1}) async {
    List<int?> result = List.filled(45, 0);
    try {
      var response = await http.get(Uri.parse(
          'https://dhlottery.co.kr/gameResult.do?method=statByNumber&sttDrwNo=${sttDrwNo}&edDrwNo=${edDrwNo}&srchType=${srchType}'));
      if (response.statusCode == 200) {
        dom.Document document = parser
            .parse(await UrlEncoder().decodeByte(response.bodyBytes, 'euc-kr'));

        Clipboard.setData(ClipboardData(text: document.text));

        var listRoot = document.getElementById('printTarget')!.children[3];

        for (int i = 0; i < listRoot.children.length; i++) {
          var ballCount = int.tryParse(listRoot.children[i].children[2].text);
          result[i] = ballCount;
        }

        return Future<List<int?>>.value(result);
      }
    } catch (e) {
      print('error - ' + e.toString());
    }
    return Future<List<int>>.error(result);
  }
}

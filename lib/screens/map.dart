import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:http/http.dart';
import 'package:lotto/const.dart';
import 'package:lotto/network/network.dart';
import 'package:lotto/screens/main.dart';
import 'package:lotto/widgets/basescreen.dart';
import 'package:lotto/widgets/const.dart';
import 'package:lotto/widgets/dialogs.dart';
import 'package:lotto/widgets/text.dart';
import 'package:lotto/widgets/widgets.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapApiKey);

class NearStoreMapPage extends StatefulWidget {
  @override
  _NearStoreMapPageState createState() => _NearStoreMapPageState();
}

class _NearStoreMapPageState extends State<NearStoreMapPage> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.48631151072069, 126.95117681416404),
    zoom: 14.4746,
  );

  Map<MarkerId, Marker> _markers = {};

  CameraPosition? _cameraPosition;

  int _loadMarkerCount = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      var position = await Geolocator.getCurrentPosition();
      var controller = await _controller.future;
      //position = Position(latitude: _kGooglePlex.target.latitude, longitude: _kGooglePlex.target.longitude);
      //controller.moveCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
      controller.moveCamera(CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude)));
      await updateMarker(position);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new BaseScreen(
      useBannerAd: false,
      title: '주변 로또 판매점 검색',
      body: Padding(
        padding: EdgeInsets.zero,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          onCameraMove: (CameraPosition position) {
            _cameraPosition = position;
          },
          onCameraIdle: () async {
            if (_cameraPosition == null) return;
            var controller = await _controller.future;
            await updateMarker(Position.fromMap({
              'latitude': _cameraPosition!.target.latitude,
              'longitude': _cameraPosition!.target.longitude
            }));
            _cameraPosition = null;
          },
          markers: _markers.values.toSet(),
        ),
      ),
    );
  }

  Future<void> updateMarker(Position positon) async {
    for (int i = 1; i <= 45; i++) {
      var placeResponse = await NetworkUtil()
          .getPlaceFromKakaoAPI('로또판매점', positon, 1000, page: i);
      debugPrint(placeResponse.places.length.toString());
      setState(() {
        placeResponse.places.forEach((element) {
          final MarkerId markerId = MarkerId(element.id!);

          final Marker marker = Marker(
            markerId: markerId,
            position: LatLng(
              element.y!,
              element.x!,
            ),
            infoWindow: InfoWindow(
                title: element.placeName, snippet: element.addressName),
            onTap: () {
              _onMarkerTapped(markerId);
            },
          );
          _markers[markerId] = marker;
        });
      });
      if (placeResponse.isEnd!) break;
    }
  }

  void _onMarkerTapped(MarkerId markerId) {}
}

List<String> nationSido = [
  '서울',
  '경기',
  '부산',
  '대구',
  '인천',
  '대전',
  '울산',
  '강원',
  '충북',
  '충남',
  '광주',
  '전북',
  '전남',
  '경북',
  '경남',
  '제주',
  '세종',
];

class NationWideStorePage extends StatefulWidget {
  NationWideStorePage({Key? key}) : super(key: key);

  @override
  _NationWideStorePageState createState() => _NationWideStorePageState();
}

class _NationWideStorePageState extends State<NationWideStorePage> {
  String _sido = '서울';
  String _gugun = '강남구';

  List<String> _guguns = [];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '전국 판매점 찾기',
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: roundBoxDecoration(),
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LottoText('지역 선택'),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            showSidoSelectPopup();
                          },
                          child: Container(
                            height: 30,
                            margin: EdgeInsets.symmetric(horizontal: 12),
                            alignment: Alignment.center,
                            decoration: roundBoxDecoration(),
                            child: LottoText(_sido),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            showGugunSelectPopup();
                          },
                          child: Container(
                            height: 30,
                            margin: EdgeInsets.symmetric(horizontal: 12),
                            alignment: Alignment.center,
                            decoration: roundBoxDecoration(),
                            child: LottoText(_gugun),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSidoSelectPopup() {
    buildDialog(
        context,
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.transparent,
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    var list = await NetworkUtil().getGugun(nationSido[index]);
                    debugPrint(list.toString());
                    setState(() {
                      _guguns = list;
                      if (_guguns.length > 0)
                        _gugun = _guguns[0];
                      else
                        _gugun = '';
                      _sido = nationSido[index];
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    color: index % 2 == 0 ? Colors.white : Colors.grey[200],
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[LottoText(nationSido[index])],
                    ),
                  ),
                );
              },
              itemCount: nationSido.length,
            ),
          ),
        ));
  }

  void showGugunSelectPopup() {
    buildDialog(
        context,
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.transparent,
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _gugun = _guguns[index];
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    color: index % 2 == 0 ? Colors.white : Colors.grey[200],
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[LottoText(_guguns[index])],
                    ),
                  ),
                );
              },
              itemCount: _guguns.length,
            ),
          ),
        ));
  }
}

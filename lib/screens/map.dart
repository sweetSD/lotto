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

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapApiKey);

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.48631151072069, 126.95117681416404),
    zoom: 14.4746,
  );

  Map<MarkerId, Marker> _markers = {};

  CameraPosition _cameraPosition;

  int _loadMarkerCount = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      var position = await getCurrentPosition();
      var controller = await _controller.future;
      //position = Position(latitude: _kGooglePlex.target.latitude, longitude: _kGooglePlex.target.longitude);
      //controller.moveCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
      controller.moveCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
      await updateMarker(position);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new BaseScreen(
      title: '주변 로또 판매점 검색',
      body: Padding(
        padding: EdgeInsets.only(bottom: 50),
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
            if(_cameraPosition == null) return;
            var controller = await _controller.future;
            await updateMarker(Position(latitude: _cameraPosition.target.latitude, longitude: _cameraPosition.target.longitude));
            _cameraPosition = null;
          },
          markers: _markers.values.toSet(),
        ),
      ),
    );
  }

  Future<void> updateMarker(Position positon) async {
    for(int i = 1; i <= 45; i++) {
      var placeResponse = await NetworkUtil().getPlaceFromKakaoAPI('로또판매점', positon, 1000, page: i);
      print(placeResponse.places.length);
      setState(() {
        placeResponse.places.forEach((element) {
          final MarkerId markerId = MarkerId(element.id);

          final Marker marker = Marker(
            markerId: markerId,
            position: LatLng(
              element.y,
              element.x,
            ),
            infoWindow: InfoWindow(title: element.placeName, snippet: element.addressName),
            onTap: () {
              //_onMarkerTapped(markerId);
            },
          );
          _markers[markerId] = marker;
        });
      });
      if(placeResponse.isEnd) break;
    }
  }

  void _onMarkerTapped(MarkerId markerId) {

  }
}
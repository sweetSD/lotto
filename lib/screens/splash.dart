import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:lotto/const.dart';
import 'package:lotto/screens/main.dart';
import 'package:lotto/widgets/text.dart';
import 'package:lotto/widgets/widgets.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      InterstitialAd.load(
          adUnitId: admobAppStartID,
          request: AdRequest(),
          adLoadCallback:
              InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
            ad.show();
            pushToMainPage();
          }, onAdFailedToLoad: (LoadAdError error) {
            pushToMainPage();
          }));
    });
  }

  void pushToMainPage() {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => MainPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenSize.width * 0.2,
            height: screenSize.width * 0.2,
            child: LoadingIndicator(indicatorType: Indicator.ballPulseSync),
          ),
        ],
      ),
    );
  }
}

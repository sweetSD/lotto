import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lotto/const.dart';
import 'package:lotto/main.dart';
import 'package:lotto/widgets/text.dart';

class BaseScreen extends StatelessWidget {
  final AppBar? appBar;

  final String title;

  final bool centerTitle;

  final bool resizeToAvoidBottomInset;

  final Widget? body;

  final Widget? leading;

  final List<Widget>? actions;

  final bool useBannerAd;

  const BaseScreen(
      {Key? key,
      this.appBar,
      this.title = '',
      this.centerTitle = true,
      this.resizeToAvoidBottomInset = true,
      this.body,
      this.leading,
      this.actions,
      this.useBannerAd = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BannerAd bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: admobBannerID,
        listener:
            BannerAdListener(onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        }),
        request: AdRequest());

    if (useBannerAd) bannerAd.load();

    return Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: appBar != null
            ? appBar
            : AppBar(
                backgroundColor: Colors.white,
                title: LottoText(
                  title,
                  size: 18,
                ),
                centerTitle: centerTitle,
                leading: leading != null
                    ? leading
                    : IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                actions: actions != null ? actions : [],
              ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Padding(
                // For Admob Banner Ad
                padding: EdgeInsets.only(bottom: useBannerAd ? 50 : 0),
                child: body,
              ),
              if (useBannerAd) ...[
                Align(
                    alignment: Alignment.bottomCenter,
                    child: bannerAdWidget(bannerAd))
              ]
            ],
          ),
        ));
  }

  Widget bannerAdWidget(BannerAd bannerAd) {
    return StatefulBuilder(
        builder: (context, setState) => Container(
              width: bannerAd.size.width.toDouble(),
              height: bannerAd.size.height.toDouble(),
              alignment: Alignment.bottomCenter,
              child: AdWidget(
                ad: bannerAd,
              ),
            ));
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lotto/network/lotto.dart';
import 'package:lotto/widgets/const.dart';
import 'package:lotto/widgets/text.dart';
import 'package:lotto/widgets/widgets.dart';

class LottoWinResultWidget extends StatelessWidget {

  final Lotto? lotto;

  final bool useDecoration;

  const LottoWinResultWidget(this.lotto, {Key? key, this.useDecoration = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.21,
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.03 ),
      decoration: useDecoration ? roundBoxDecoration() : null,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextBinggrae('제${lotto!.drawNumber}회', color: Colors.blue,),
              TextBinggrae(' 당첨번호'),
            ],
          ),
          TextBinggrae('${DateFormat('yyyy-MM-dd').format(lotto!.drawAt!)} 추첨', size: 10,),
          Space(MediaQuery.of(context).size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LottoBall(lotto!.drawNo1),
              Space(MediaQuery.of(context).size.width * 0.02),
              LottoBall(lotto!.drawNo2),
              Space(MediaQuery.of(context).size.width * 0.02),
              LottoBall(lotto!.drawNo3),
              Space(MediaQuery.of(context).size.width * 0.02),
              LottoBall(lotto!.drawNo4),
              Space(MediaQuery.of(context).size.width * 0.02),
              LottoBall(lotto!.drawNo5),
              Space(MediaQuery.of(context).size.width * 0.02),
              LottoBall(lotto!.drawNo6),
              Space(MediaQuery.of(context).size.width * 0.02),
              Icon(FontAwesomeIcons.plus, size: MediaQuery.of(context).size.width * 0.04,),
              Space(MediaQuery.of(context).size.width * 0.02),
              LottoBall(lotto!.drawBonus),
            ],
          ),
        ],
      ),
    );
  }
}

class LottoPickWidget extends StatelessWidget {

  final int? index;

  final List<int> picks;

  final List<int?>? result;

  final int? rank;

  final Color color;

  final bool onlyPicks;

  const LottoPickWidget(this.picks, {Key? key, this.index, this.rank, this.color = const Color(0xffeeeeee), this.result, this.onlyPicks = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.125,
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.03 ),
      color: color,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: onlyPicks ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if(!onlyPicks) ... [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: index != null ? TextBinggrae(String.fromCharCode(65 + index!)) : Space(0),
                ),
                Container(
                  child: rank != null ? TextBinggrae(rank! > 0 ? '${rank}등당첨' : '낙첨') : Space(0),
                ),
              ],
              Row(
                children: <Widget>[
                  for(int i = 0; i < picks.length; i++) ... [
                    result != null && !result!.contains(picks[i]) ? LottoBall(picks[i], textColor: Colors.black, backgroundColor: Colors.transparent, useShadow: false,) : LottoBall(picks[i]),
                    Space(MediaQuery.of(context).size.width * 0.02),
                  ]
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
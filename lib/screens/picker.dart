import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lotto/network/network.dart';
import 'package:lotto/screens/lotto.dart';
import 'package:lotto/screens/main.dart';
import 'package:lotto/widgets/basescreen.dart';
import 'package:lotto/widgets/const.dart';
import 'package:lotto/widgets/dialogs.dart';
import 'package:lotto/widgets/lotto.dart';
import 'package:lotto/widgets/text.dart';
import 'package:lotto/widgets/widgets.dart';

class NumberPickPage extends StatefulWidget {

  List<DateTime> _drawDates;

  NumberPickPage(this._drawDates, {Key key}) : super(key: key);

  @override
  _NumberPickPageState createState() => _NumberPickPageState();
}

class _NumberPickPageState extends State<NumberPickPage> {

  List<int> _picks = [];

  DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget._drawDates[0];
  }

  @override
  Widget build(BuildContext context) {

    getSelectableLottoBall(int number) {
      return 1 <= number && number <= 45 ? GestureDetector(
        onTap: () {
          if(_picks.length >= 6) return;
          setState(() {
            _picks.add(number);
            _picks = _picks.toSet().toList();
            _picks.sort();
          });
        },
        child: LottoBall(number),
      ) : Space(MediaQuery.of(context).size.width * 0.1);
    }

    return BaseScreen(
      title: '번호 선택',
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Space(10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      showSelectDrawPopup();
                    },
                    child: Container(
                      height: 30,
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: roundBoxDecoration(),
                      child: TextBinggrae('${calculateDrawNum(_selectedDate)}회 (${DateFormat('yyyy-MM-dd').format(_selectedDate)})'),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if(_picks.length < 6) {
                        Fluttertoast.showToast(msg: '숫자 6개를 모두 선택해주세요.');
                        return;
                      }
                      var lotto = await NetworkUtil().getLottoNumber(calculateDrawNum(_selectedDate));
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LottoResultPage(lotto, _picks)));
                    },
                    child: Container(
                      height: 30,
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: roundBoxDecoration(),
                      child: TextBinggrae('확인하기'),
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 30, thickness: 1, color: Colors.grey[200],),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _picks.map((e) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5), 
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _picks.remove(e);
                      });
                    },
                    child: LottoBall(e,),
                  ),
                )).toList(),
              ),
            ),
            Divider(height: 30, thickness: 1, color: Colors.grey[200],),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 6,
                separatorBuilder: (context, index) => Space(20),
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for(int i = 1; i <= 8; i++) getSelectableLottoBall(index * 8 + i),
                    ],
                  );
                },
              ),
            ),
            Space(60),
          ],
        ),
      ),
    );
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
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = widget._drawDates[index];
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  color: index % 2 == 0 ? Colors.white : Colors.grey[200], 
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextBinggrae('${calculateDrawNum(widget._drawDates[index])}회 (${DateFormat('yyyy-MM-dd').format(widget._drawDates[index])})')
                    ],
                  ),
                ),
              );
            },
            itemCount: widget._drawDates.length,
          ),
        ),
      )
    )
    ..show();
  }
}
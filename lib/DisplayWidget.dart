import 'package:flutter/material.dart';
import "package:intl/intl.dart";

import 'currencyInfo.dart';

class DisplayWidget extends StatefulWidget {
  final Map<String, num> numData;
  final Map<String, String> stringData;

  DisplayWidget({Key key, this.numData, this.stringData}) : super(key: key);

  @override
  State createState() => _DisplayState();
}

class _DisplayState extends State<DisplayWidget>{

  void initState() {
    super.initState();
  }

  String getTodayString(){
    DateTime dt = DateTime.now().toLocal();
    return DateFormat('yyyyMMdd').format(dt);
  }

  String getMoneyString(num amount){
    return currencyInfo().getCurrencyText(widget.stringData["currency"], amount);
  }

  // Currently defaults is US Dollars
  Widget _moneyText(num amount) {
    return Center(
        child: Text(getMoneyString(amount),
            style: TextStyle(fontSize: 40.0, color: getColor(amount))));
  }

  // Returns color for text based on the amount.
  Color getColor(i) {
    if (i < 0) return Colors.red;
    if (i > 0) return Colors.lightGreen;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.fromLTRB(0, 20, 0, 10),
          child:Center(
              child: Text("Remaining Balance",
                style: TextStyle(fontSize: 20.0,),
              )
          ),
        ),
        _moneyText(widget.numData["balance"]),
      ],
    );
  }
}
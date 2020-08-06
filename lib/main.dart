import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'HomeWidget.dart';
import 'SplashWidget.dart';
import 'database_helper.dart';

void main() => runApp(Phoenix(child: MyApp()));

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Simple Ledger',
        theme: ThemeData(
          primaryColor: Color.fromRGBO(155, 195, 255, 1),
        ),
        home: MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  State createState() => _MainState();
}

class _MainState extends State<MainApp> {
  Map<String, num> numData;
  Map<String, String> stringData;
  List<SpendingEntry> spending;
  List<SubscriptionEntry> subscriptions;

  @override
  void initState() {
    super.initState();
    numData = new Map<String, num>();
    stringData = new Map<String, String>();
    loadValues();
  }

  loadValues(){
    // Set/Get String Values
    stringData["spendContent"] = "";

    _readSP("currency").then((val) {setState(() {stringData["currency"] = val == null? "USD" : val;});});
    _readSP("today").then((val) {setState(() {numData["today"] = val == null ? 0 : val;});});

    // Set/Get Num Values from Shared Prefs
    numData["spendAmount"] = 0;

    _readSP("balance").then((val) {setState(() {numData["balance"] = val == null? 0 : val;});});
    _readSP("seenIntro").then((val) {setState(() {numData["seenIntro"] = val == null? 0 : 1;});});

    // Get System Values
    _readSP("historyMode").then((val) {setState(() {stringData["historyMode"] = val == null ? "daily" : val;});});
    _readSP("version").then((val) {setState(() {numData["version"] = val == null ? 0.1 : val;});});

    // Load Spendings from DB
    _queryDBAllSpending().then((entries) {setState(() {
      spending = entries;
    });});
    _queryDBAllSubscription().then((entries) {setState(() {
      subscriptions = entries;
    });});
  }

  dataIsLoaded(){
    return numData != null && numData["balance"] != null && spending != null && subscriptions != null;
  }

  Future routeScreen() async {

    if (numData["seenIntro"] == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) =>
            HomeWidget(numData: numData, stringData: stringData, spending: spending, subscriptions: subscriptions, parentCtx: context)),
            (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => SplashWidget(data: numData, spending: spending,)),
            (Route<dynamic> route) => false,
      );
    }
  }

  Widget build(BuildContext context){

    if(dataIsLoaded()) {
      new Timer(new Duration(milliseconds: 700), () {
        routeScreen();
      });
    }
    return Scaffold(
        body: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15),
                child: Center(
                    child: Image(
                      image: AssetImage('assets/my_icon.png'),
                      width: 150,
                    )),
              ),
            ])
    );
  }

  Future<List<SpendingEntry>> _queryDBAllSpending() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    return await helper.queryAllSpending();
  }

  Future<List<SubscriptionEntry>> _queryDBAllSubscription() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    return await helper.queryAllSubscriptions();
  }

  // Reading from Shared Preferences
  Future<dynamic> _readSP(String key) async {
    final prefs = await SharedPreferences.getInstance();
    dynamic value = prefs.get(key);
    return value;
  }

  _saveSP(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if(value is String) {prefs.setString(key, value);}
    else if(value is bool) {prefs.setBool(key, value);}
    else if(value is int) {prefs.setInt(key, value);}
    else if(value is double) {prefs.setDouble(key, value);}
    else {prefs.setStringList(key, value);}
  }
}

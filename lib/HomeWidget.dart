import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simple_ledger/DisplayWidget.dart';
import 'package:simple_ledger/HistoryWidget.dart';
import 'package:simple_ledger/SpendMoneyWidget.dart';
  import 'package:simple_ledger/SettingsWidget.dart';

class HomeWidget extends StatefulWidget {
  final Map<String, num> numData;
  final Map<String, String> stringData;
  final List<SpendingEntry> spending;
  final List<SubscriptionEntry> subscriptions;
  final BuildContext parentCtx;

  HomeWidget({Key key, this.numData, this.stringData, this.spending, this.subscriptions, this.parentCtx}) : super(key: key);

  @override
  State createState() => _HomeState();

}

class _HomeState extends State<HomeWidget>{
  final pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  @override
  void initState(){
    super.initState();
    checkNewDay();

    SystemChannels.lifecycle.setMessageHandler((msg){
      if(msg==AppLifecycleState.resumed.toString()) {
        checkNewDay();
      }
      return null;
    });
  }

  List<DateTime> calculateDaysInterval(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    DateTime tmp = DateTime(startDate.year, startDate.month, startDate.day, 12);
    while(DateTime(tmp.year, tmp.month, tmp.day) != endDate){
      tmp = tmp.add(new Duration(days: 1));
      days.add(DateTime(tmp.year, tmp.month, tmp.day));
    }

    return days;
  }

  void addSubscriptionEntry(SubscriptionEntry i, DateTime dt){

    SpendingEntry subscriptionEntry = new SpendingEntry();
    subscriptionEntry.day = dt.millisecondsSinceEpoch;
    subscriptionEntry.timestamp = DateTime(dt.year, dt.month, dt.day).millisecondsSinceEpoch;
    subscriptionEntry.amount = i.amount * -1;
    subscriptionEntry.content = i.content + " (Subscription)";

    _saveDBSpending(subscriptionEntry);

    widget.numData["balance"] -= i.amount;
    _saveSP("balance", widget.numData["balance"]);

  }

  void checkNewDay(){
    DateTime now = DateTime.now().toLocal();
    num today = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    if(widget.numData["today"] == 0){
      widget.numData["today"] = today;
      _saveSP("today", today);
    }

    if(widget.numData["today"] != today){
      for(DateTime dt in calculateDaysInterval(DateTime.fromMillisecondsSinceEpoch(widget.numData["today"]), DateTime.fromMillisecondsSinceEpoch(today))) {
        for(SubscriptionEntry i in widget.subscriptions){
          DateTime renew = DateTime.fromMillisecondsSinceEpoch(i.day);
          if (renew.day == dt.day){
            if (i.cycle == 0) {
              addSubscriptionEntry(i, dt);
            } else {
              if (renew.month == dt.month) {
                addSubscriptionEntry(i, dt);
              }
            }
          }
        }
      }

      // New Date and reset
      widget.numData["today"] = today;
      _saveSP("today", today);
      setState((){});
    }
  }

  void _pushSettings(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsWidget(numData: widget.numData, stringData: widget.stringData, subscriptions: widget.subscriptions),
        ));
    setState(() {});
    if(result){
      Phoenix.rebirth(widget.parentCtx);
    }
  }

  List<Widget> _children() => [
    SpendMoneyWidget(numData: widget.numData, stringData: widget.stringData),
    DisplayWidget(numData: widget.numData, stringData: widget.stringData,),
    HistoryWidget(numData: widget.numData, stringData: widget.stringData,)
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = _children();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Color.fromRGBO(155, 195, 255, 1),
        title: Text("Simple Ledger"),
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                _pushSettings(context);
              }
          )
        ],
      ),
      body: PageView(
          onPageChanged: (index) {
            FocusScope.of(context).unfocus();
            changePage(index);
          },
          controller: pageController,
          children: children
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        selectedItemColor: Color.fromRGBO(155, 195, 255, 1),
        currentIndex: _currentIndex, // new
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.attach_money),
            title: new Text('Spend'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.insert_chart),
            title: new Text('Display'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.history),
            title: new Text('History'),
          ),
        ],
      ),
    );
  }

  changePage(int index){
    setState(() {
      _currentIndex = index;
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  _saveSP(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if(value is String) {prefs.setString(key, value);}
    else if(value is bool) {prefs.setBool(key, value);}
    else if(value is int) {prefs.setInt(key, value);}
    else if(value is double) {prefs.setDouble(key, value);}
    else {prefs.setStringList(key, value);}
  }

  _saveDBSpending(SpendingEntry entry) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.insertSpending(entry);
  }
}
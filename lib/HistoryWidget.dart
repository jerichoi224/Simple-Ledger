import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';
import 'currencyInfo.dart';
import 'EditSpendingWidget.dart';

class HistoryWidget extends StatefulWidget {
  final Map<String, num> numData;
  final Map<String, String> stringData;

  HistoryWidget({Key key, this.numData, this.stringData}) : super(key: key);

  @override
  State createState() => _HistoryState();
}

class _HistoryState extends State<HistoryWidget> with WidgetsBindingObserver{
  String dayString;
  int today;
  DateTime _day;
  List<SpendingEntry> spendingList;

  @override
  void initState(){
    super.initState();

    DateTime now = DateTime.now().toLocal();
    today = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    _day = DateTime.now().toLocal();
    spendingList = new List<SpendingEntry>();

    _queryDBAllSpending().then((entries){
      setState(() {spendingList = entries;});
    });
  }

  String dayToString(DateTime dt){
    return DateFormat('yyyy/MM/dd').format(dt);
  }

  String getMoneyString(num amount){
    return currencyInfo().getCurrencyText(widget.stringData["currency"], amount);
  }

  TextSpan _moneyText(num amount) {
    return TextSpan(text: getMoneyString(amount),
        style: TextStyle(color: getColor(amount)));
  }

  Color getColor(i) {
    if (i < 0) return Colors.red;
    if (i > 0) return Colors.green;
    return Colors.black;
  }

  void _openEditWidget(SpendingEntry item) async {
    String oldContent = item.content;
    double oldAmount = item.amount;

    final SpendingEntry result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditSpendingWidget(item: item, currency: widget.stringData["currency"],),
        )
    );

    if(result.content == oldContent && result.amount == oldAmount){
      return;
    }

    for(SpendingEntry i in spendingList){
      if(i.id == result.id){
        i.content = result.content;
        i.amount = result.amount;
        widget.numData["balance"] -= oldAmount;
        widget.numData["balance"] += result.amount;
        _saveSP("balance", widget.numData["balance"]);
        _updateDBSpending(i);
      }
    }
    // Update any values that have changed.
    setState(() {});
  }

  titleText(){
    if(widget.stringData["historyMode"] == "entire"){
      return "Spending History";
    }
    return dayToString(_day) == dayToString(DateTime.now().toLocal()) ? "Today's Spending" : "Spending on $dayString";
  }

  _popUpMenuButton(SpendingEntry i) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      onSelected: (selectedIndex) { // add this property
        if(selectedIndex == 1){
          _deleteDBSpending(i.id);
          spendingList.remove(i);
          widget.numData["balance"] -= i.amount;
          _saveSP("balance", widget.numData["balance"]);
          setState(() {});
        }
        else if(selectedIndex == 0){
          _openEditWidget(i);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Text("Edit"),
          value: 0,
        ),
        PopupMenuItem(
          child: Text("Delete"),
          value: 1,
        ),
      ],
    );
  }

  getTimeText(SpendingEntry i){
    DateTime dt = new DateTime.fromMillisecondsSinceEpoch(i.timestamp);
    return "\t\t(" + DateFormat('h:mm a').format(dt) + ")";
  }

  List<Widget> spendingHistory(){
    List<Widget> history = new List<Widget>();
    int tmp = 0;
    for(SpendingEntry i in spendingList.reversed){
      // If In Daily Mode, skip anything from other dates
      if(widget.stringData["historyMode"] == "daily" && i.day != today){
        continue;
      }
      // If in Entire History Mode, show date changes
      if(widget.stringData["historyMode"] == "entire" && tmp != i.day){
        tmp = i.day;
        history.add(
            Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text(dayToString(DateTime.fromMillisecondsSinceEpoch(tmp)),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54
                  ),
                )
            )
        );
      }
      history.add(
          new Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: EdgeInsets.all(5.0),
              color: Colors.white,
              child: ListTile(
                  dense: true,
                  title: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        _moneyText(i.amount),
                        TextSpan(text: getTimeText(i),
                            style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                  subtitle: Text(
                      i.content == "" ? "No Description" : i.content),
                  trailing: _popUpMenuButton(i)
              )
          )
      );
    }
    return history.length > 0 ? history : List.from(
        [Text("Nothing Found Here!")]);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0, 25, 0, 20),
                child: ListTile(
                  dense: true,
                  leading: Visibility(
                    visible: widget.stringData["historyMode"] == "daily",
                    child: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: (){
                        showDatePicker(
                          context: context,
                          initialDate: _day,
                          firstDate: DateTime(2001),
                          lastDate: DateTime.now(),
                          builder: (BuildContext context, Widget child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color.fromRGBO(155, 195, 255, 1),
                                  onPrimary: Colors.white,
                                ),
                                buttonTheme: ButtonThemeData(
                                  buttonColor: Color.fromRGBO(155, 195, 255, 1),
                                ),
                              ),
                              child: child,
                            );
                          },
                        ).then((value) {
                          if(value != null) {
                            setState(() {
                              _day = value;
                              dayString = dayToString(_day);
                            });
                          }
                        });
                      },
                    ),
                  ),
                  title: Text(titleText(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )
                  ),
                ),
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: spendingHistory()
              )
            ]
        )
    );
  }

  _deleteDBSpending(int id) async{
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.deleteSingleEntry(id);
  }

  _saveSP(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if(value is String) {prefs.setString(key, value);}
    else if(value is bool) {prefs.setBool(key, value);}
    else if(value is int) {prefs.setInt(key, value);}
    else if(value is double) {prefs.setDouble(key, value);}
    else {prefs.setStringList(key, value);}
  }

  _updateDBSpending(SpendingEntry entry) async{
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.updateSingleEntry(entry);
  }

  Future<List<SpendingEntry>> _queryDBAllSpending() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    return await helper.queryAllSpending();
  }
}
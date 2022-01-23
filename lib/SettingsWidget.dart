import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simple_ledger/database_helper.dart';
import 'package:simple_ledger/EditSubscriptionWidget.dart';
import 'package:simple_ledger/SubscriptionListWidget.dart';

class SettingsWidget extends StatefulWidget {
  final dateController = TextEditingController();
  final Map<String, num> numData;
  final Map<String, String> stringData;
  final List<SubscriptionEntry> subscriptions;

  SettingsWidget({Key key, this.numData, this.stringData, this.subscriptions}) : super(key: key);

  @override
  State createState() => _SettingsState();
}

class _SettingsState extends State<SettingsWidget> {
  bool showEntireHistory, confirmed;
  String currency;

  @override
  void initState() {
    super.initState();
    confirmed = false;
    currency = widget.stringData["currency"];
    showEntireHistory = widget.stringData["historyMode"] == "entire";
  }

  bool isInt(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  void _openEditSubscription(BuildContext ctx) async{
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditSubscriptionWidget(mode: "NEW", item: null, ctx: ctx, currency: widget.stringData["currency"],),
        ));

    // Save any new Subscriptions
    if (result != null) {
      widget.subscriptions.add(result);
      setState(() {
        _saveSubscription(result);
        FocusScope.of(context).unfocus();
      });
    }
  }

  Future<void> _showMyDialog(String newValue, BuildContext ctx) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Changing the currency will clear all data and restart. Please back up your data if you need to.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                FocusScope.of(context).unfocus();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Confirm'),
              onPressed: () {
                Scaffold.of(ctx).showSnackBar(SnackBar(
                  content: Text('Data will be cleared on Save'),
                  duration: Duration(seconds: 5),
                ));
                setState(() {
                  currency = newValue;
                });
                FocusScope.of(context).unfocus();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openSubscriptionList(){
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => SubscriptionListWidget(subscriptions: widget.subscriptions, currency: widget.stringData["currency"],),
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async{
      Navigator.pop(context, false);
      return true;
      },
        child: new GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: new Scaffold(
                appBar: AppBar(
                  backgroundColor: Color.fromRGBO(155, 195, 255, 1),
                  foregroundColor: Colors.black,
                  title: Text("Settings"),
                ),
                body: Builder(
                    builder: (context) =>
                        SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // System Values
                                Container(
                                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                    child: Text("System Values",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey
                                      ),
                                    )
                                ),
                                Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    margin: EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                            title: new Row(
                                              children: <Widget>[
                                                Text("Currency"),
                                                Spacer(),
                                                DropdownButton<String>(
                                                  value: currency,
                                                  iconSize: 24,
                                                  elevation: 16,
                                                  underline: Container(
                                                    height: 2,
                                                  ),
                                                  onChanged: (String newValue) {
                                                    if(newValue != currency){
                                                      _showMyDialog(newValue, context);
                                                    }
                                                  },
                                                  items: <String>['USD', 'KRW']
                                                      .map<DropdownMenuItem<String>>((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                )
                                              ],
                                            )
                                        )
                                      ],
                                    )
                                ),
                                // System UI
                                Container(
                                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                    child: Text("System UI",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey
                                      ),
                                    )
                                ),
                                Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    margin: EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                            title: new Row(
                                              children: <Widget>[
                                                new Text("Show Entire History"),
                                                Spacer(),
                                                Switch(
                                                  value: showEntireHistory,
                                                  onChanged: (value){
                                                    setState(() {
                                                      showEntireHistory = value;
                                                    });
                                                  },
                                                  activeTrackColor:  Color.fromRGBO(74, 146, 253, 1),
                                                  activeColor:  Color.fromRGBO(155, 195, 255, 1),
                                                ),
                                              ],
                                            )
                                        ),
                                      ],
                                    )
                                ),
                                // Manage Subscriptions
                                Container(
                                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                    child: Text("Manage Subscriptions",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey
                                      ),
                                    )
                                ),
                                Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    margin: EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        ListTile(
                                            onTap: (){
                                              _openEditSubscription(context);
                                            },
                                            title: new Row(
                                              children: <Widget>[
                                                new Text("Add New Subscription"),
                                              ],
                                            )
                                        ),
                                        ListTile(
                                            onTap: (){
                                              _openSubscriptionList();
                                            },
                                            title: new Row(
                                              children: <Widget>[
                                                new Text("View Subscriptions"),
                                              ],
                                            )
                                        ),
                                      ],
                                    )
                                ),
                                Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    color: Color.fromRGBO(155, 195, 255, 1),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          ListTile(
                                              onTap:(){
                                                bool reset = false;
                                                widget.stringData["historyMode"] = "daily";
                                                if(showEntireHistory){
                                                  widget.stringData["historyMode"] = "entire";
                                                }
                                                _save("historyMode", widget.stringData["historyMode"]);

                                                if(currency != widget.stringData["currency"]){
                                                  _save("currency", currency);
                                                  _save("balance", 0);

                                                  _clearDB();
                                                  reset = true;

                                                }

                                                Navigator.pop(context, reset);
                                              },
                                              title: Text("Save Setting",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                ),
                                                textAlign: TextAlign.center,
                                              )
                                          )
                                        ]
                                    )
                                ),// Save Button
                              ],
                            )
                        )
                )
            )
        )
    );
  }

  _saveSubscription(SubscriptionEntry entry) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.insertSubscription(entry);
  }

  _save(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    if(data is String) {prefs.setString(key, data);}
    else if(data is bool) {prefs.setBool(key, data);}
    else if(data is int) {prefs.setInt(key, data);}
    else if(data is double) {prefs.setDouble(key, data);}
    else {prefs.setStringList(key, data);}  }

  _clearDB() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    helper.clearSpendingTable();
    helper.clearSubscriptionTable();
  }
}
import 'package:flutter/material.dart';
import 'database_helper.dart';

class SplashWidget extends StatefulWidget {
  final Map<String, num> data;
  final List<SpendingEntry> spending;

  SplashWidget({Key key, this.data, this.spending}) : super(key: key);

  @override
  State createState() => _SplashState();

}

class _SplashState extends State<SplashWidget>{

  @override
  Widget build(BuildContext context) {

  }
}
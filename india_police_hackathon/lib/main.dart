import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:india_police_hackathon/resources/RoutesData.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'India Police Hackathon 2019',
      onGenerateRoute: Router.generateRoute,
      initialRoute: '/dashboard',
      theme: ThemeData(primarySwatch: Colors.brown, fontFamily: 'Poppins'),
    );
  }
}

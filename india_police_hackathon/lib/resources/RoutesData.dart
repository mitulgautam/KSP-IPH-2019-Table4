import 'package:flutter/material.dart';
import 'package:india_police_hackathon/view/DashboardView.dart';
import 'package:india_police_hackathon/view/LoginView.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LoginView());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => DashboardView());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text(' No routes defined for ${setting.name}'),
                  ),
                ));
    }
  }
}

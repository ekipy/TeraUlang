import 'package:flutter/material.dart';
import 'package:tera_ulang/data/data_screen.dart';
import 'package:tera_ulang/screen/home_screen.dart';
import 'package:tera_ulang/screen/login_screen.dart';
import 'package:tera_ulang/screen/monitoring_screen.dart';
import 'package:tera_ulang/screen/register_screen.dart';
import 'package:tera_ulang/screen/report_screen.dart';
import 'package:tera_ulang/screen/splash_screen.dart';
import 'package:tera_ulang/screen/tera_ulang_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/tera_form':
        return MaterialPageRoute(builder: (_) => const TeraUlangScreen());
      case '/data':
        return MaterialPageRoute(builder: (_) => const DataScreen());
      case '/monitoring':
        return MaterialPageRoute(builder: (_) => const MonitoringScreen());
      case '/report':
        return MaterialPageRoute(builder: (_) => const ReportScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}

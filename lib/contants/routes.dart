import 'package:flutter/material.dart';
import 'package:ltrc/views/main_page_view.dart';
import 'package:ltrc/views/register_view.dart';
import 'package:ltrc/views/units_view.dart';


class AppRoutes {
  AppRoutes._();

  static const String register = '/auth-login';
  static const String mainPage = '/mainPage';
  static const String units = '/units';

  static Map<String, WidgetBuilder> define() {
    return {
      register: (context) => const RegisterView(),
      mainPage: (context) => const MainPageView(),
      units: (context) => const UnitsView(),
    };
  }
}
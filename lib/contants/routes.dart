import 'package:flutter/material.dart';
import 'package:ltrc/views/bopomos_view.dart';
import 'package:ltrc/views/main_page_view.dart';
import 'package:ltrc/views/register_view.dart';
import 'package:ltrc/views/teach_word_view.dart';
import 'package:ltrc/views/units_view.dart';
import 'package:ltrc/views/words_view.dart';
import 'package:ltrc/views/register_account_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String register = '/register';
  static const String registerAccount = '/registerAccount';
  static const String mainPage = '/mainPage';
  static const String units = '/units';
  static const String words = '/words';
  static const String teachWord = '/teachWord';
  static const String bopomos = '/bopomos';

  static Map<String, WidgetBuilder> define() {
    return {
      register: (context) => const RegisterView(),
      mainPage: (context) => const MainPageView(),
      units: (context) => const UnitsView(),
      words: (context) => const WordsView(),
      teachWord: (context) => const TeachWordView(),
      bopomos: (context) => BopomosView(),
      registerAccount: (context) => const RegisterAccountView(),
    };
  }
}

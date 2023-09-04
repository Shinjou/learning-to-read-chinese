import 'package:flutter/material.dart';
import 'package:ltrc/views/bopomo_spelling.dart';
import 'package:ltrc/views/bopomos_view.dart';
import 'package:ltrc/views/main_page_view.dart';
import 'package:ltrc/views/register_view.dart';
import 'package:ltrc/views/reset_password.dart';
import 'package:ltrc/views/reset_pwd_account.dart';
import 'package:ltrc/views/safety_hint_register_view.dart';
import 'package:ltrc/views/safety_hint_verify_view.dart';
import 'package:ltrc/views/teach_word_view.dart';
import 'package:ltrc/views/units_view.dart';
import 'package:ltrc/views/words_view.dart';
import 'package:ltrc/views/register_account_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String register = '/register';
  static const String registerAccount = '/registerAccount';
  static const String resetPwdAccount = '/resetPwdAccount';
  static const String mainPage = '/mainPage';
  static const String units = '/units';
  static const String words = '/words';
  static const String teachWord = '/teachWord';
  static const String bopomos = '/bopomos';
  static const String bopomoSpelling = '/bopomoSpelling';
  static const String safetyHintRegister = '/safetyHintRegister';
  static const String safetyHintVerify = '/safetyHintVerify';
  static const String setNewPwd = '/setNewPwd';

  static Map<String, WidgetBuilder> define() {
    return {
      register: (context) => const RegisterView(),
      mainPage: (context) => const MainPageView(),
      units: (context) => const UnitsView(),
      words: (context) => const WordsView(),
      // teachWord: (context) => TeachWordView(),
      bopomos: (context) => BopomosView(),
      bopomoSpelling: (context) => const BopomoSpellingView(),
      registerAccount: (context) => const RegisterAccountView(),
      resetPwdAccount: (context) => const ResetPwdAccountView(),
      safetyHintRegister: (context) => const SafetyHintRegisterView(),
      safetyHintVerify: (context) => const SafetyHintVerifyView(),
      setNewPwd: (context) => const ResetPwdView(),
    };
  }
}

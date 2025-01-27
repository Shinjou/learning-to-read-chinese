import 'package:flutter/material.dart';
import 'package:ltrc/views/acknowledge.dart';
import 'package:ltrc/views/check_zhuyin_view.dart';
import 'package:ltrc/views/bopomo_quiz.dart';
import 'package:ltrc/views/bopomo_quiz_finish.dart';
import 'package:ltrc/views/bopomos_view.dart';
import 'package:ltrc/views/duoyinzi_view.dart';
import 'package:ltrc/views/log_in_view.dart';
import 'package:ltrc/views/main_page_view.dart';
import 'package:ltrc/views/register_account_view.dart';
import 'package:ltrc/views/register_view.dart';
import 'package:ltrc/views/reset_password.dart';
import 'package:ltrc/views/reset_pwd_account.dart';
import 'package:ltrc/views/safety_hint_register_view.dart';
import 'package:ltrc/views/safety_hint_verify_view.dart';
import 'package:ltrc/views/setting_view.dart';
import 'package:ltrc/views/units_view.dart';
import 'package:ltrc/views/words_view.dart';


class AppRoutes {
  AppRoutes._();
  static const String acknowledge = '/acknowledge';
  static const String bopomos = '/bopomos';
  static const String bopomoQuiz = '/bopomoQuiz';
  static const String bopomoQuizFinish = '/bopomoQuizFinish';
  static const String login = '/login';
  static const String mainPage = '/mainPage';
  static const String register = '/register';
  static const String registerAccount = '/registerAccount';
  static const String resetPwdAccount = '/resetPwdAccount';
  static const String safetyHintRegister = '/safetyHintRegister';
  static const String safetyHintVerify = '/safetyHintVerify';
  static const String setNewPwd = '/setNewPwd';
  static const String setting = '/setting';
  static const String teachWord = '/teachWord';
  static const String units = '/units';
  static const String words = '/words';
  static const String duoyinzi = '/duoyinzi';
  static const String checkzhuyin = '/checkzhuyin';  // To test zhuyin


  static Map<String, WidgetBuilder> define() {
    return {
      acknowledge: (context) => const AcknowledgeView(),
      bopomos: (context) => const BopomosView(),
      bopomoQuiz: (context) => const BopomoQuizView(),
      bopomoQuizFinish: (context) => const BopomoQuizFinishView(),
      login: (context) => const LogInView(),
      mainPage: (context) => const MainPageView(),
      register: (context) => const RegisterView(),
      registerAccount: (context) => const RegisterAccountView(),
      resetPwdAccount: (context) => const ResetPwdAccountView(),
      safetyHintRegister: (context) => const SafetyHintRegisterView(),
      safetyHintVerify: (context) => const SafetyHintVerifyView(),
      setNewPwd: (context) => const ResetPwdView(),
      setting: (context) => const SettingView(),
      units: (context) => const UnitsView(),
      words: (context) => const WordsView(),
      duoyinzi: (context) => const DuoyinziView(),
      checkzhuyin: (context) => const CheckZhuyinView(), // To test zhuyin
      // teachWord: (context) => const TeachWordView(),
    };
  }
}

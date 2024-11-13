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
import 'package:ltrc/views/sw_version_view.dart';
// import 'package:ltrc/views/teach_word_view.dart';
import 'package:ltrc/teach_word/presentation/teach_word_view_testing.dart';
import 'package:ltrc/views/units_view.dart';

import 'package:ltrc/views/words_view.dart';
// to pass contextProvider and wordControllerProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/controllers/word_controller.dart';
import 'package:ltrc/teach_word/providers/teach_word_providers.dart';
import 'package:ltrc/teach_word/providers/word_provider.dart';
// import 'package:ltrc/views/view_utils.dart';
//

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
  static const String swversion = '/swversion';
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
      swversion: (context) => const SwVersionView(),
      units: (context) => const UnitsView(),
      words: (context) => const WordsView(),
      duoyinzi: (context) => const DuoyinziView(),
      checkzhuyin: (context) => const CheckZhuyinView(), // To test zhuyin
      /* works for screenInfo, but not wordControllerProvider
      teachWord: (context) {
        // Extract arguments directly for use in TeachWordView
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return TeachWordView(
          unitId: args['unitId'],
          unitTitle: args['unitTitle'],
          wordsStatus: args['wordsStatus'],
          wordsPhrase: args['wordsPhrase'],
          wordIndex: args['wordIndex'],
        );
      },
      */

      // Another try to pass contextProvider and wordControllerProvider
      teachWord: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

        return ProviderScope(
          overrides: [
            contextProvider.overrideWithValue(context),
            wordControllerProvider.overrideWith((ref) => WordController(
              context,
              ref,
              ref.read(ttsProvider),                // Text-to-Speech instance
              ref.read(audioPlayerProvider),         // Audio player instance
              ref.read(wordServiceProvider),         // Word service instance
              ref.watch(initialWordStateProvider),   // Initial state for WordController
            )),
          ],
          child: TeachWordView(
            unitId: args['unitId'],
            unitTitle: args['unitTitle'],
            wordsStatus: args['wordsStatus'],
            wordsPhrase: args['wordsPhrase'],
            wordIndex: args['wordIndex'],
          ),
        );
      },


      /*
      teachWord: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        
        return ProviderScope(
          overrides: [
            contextProvider.overrideWithValue(context),
            screenInfoProvider.overrideWith((ref) => ScreenInfoNotifier()),

            // Only override `wordControllerProvider` for `TeachWordView`
            wordControllerProvider.overrideWith((ref) => WordController(
              context,
              ref,
              ref.read(ttsProvider),                // Text-to-Speech instance
              ref.read(audioPlayerProvider),         // Audio player instance
              ref.read(wordServiceProvider),         // Word service instance
              ref.watch(initialWordStateProvider),   // Initial state for WordController
            )),
          ],
          child: TeachWordView(
            unitId: args['unitId'],
            unitTitle: args['unitTitle'],
            wordsStatus: args['wordsStatus'],
            wordsPhrase: args['wordsPhrase'],
            wordIndex: args['wordIndex'],
          ),
        );
      },
      */
    };
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/views/view_utils.dart';

final soundSpeedProvider = StateProvider<double>((ref) => 0.5);
final zhuyinOnProvider = StateProvider<bool>((ref) => true);

final gradeProvider = StateProvider<int>((ref) => 1);
final publisherCodeProvider = StateProvider<int>((ref) => 0);
final semesterCodeProvider = StateProvider<int>((ref) => 0); // was 上 0: 上, 1: 下
final accountProvider = StateProvider<String>((ref) => "");
final pwdProvider = StateProvider<String>((ref) => "");
final teachWordViewProvider = StateProvider<int>((ref) => 0);
final userNameProvider = StateProvider<String>((ref) => "");
final totalWordCountProvider = StateProvider<int>((ref) => 186);
final learnedWordCountProvider = StateProvider<int>((ref) => 0);


final screenInfoProvider = StateProvider<ScreenInfo>((ref) {
  // This provider must be overridden where BuildContext is available
  throw UnimplementedError('Override this provider in a Widget that has access to BuildContext.');
});
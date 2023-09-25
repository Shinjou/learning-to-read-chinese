import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundOnProvider = StateProvider((ref) => true);
final chuyinOnProvider = Provider((ref) => true);

final gradeProvider = StateProvider<int>((ref) => 1);
final publisherCodeProvider = StateProvider<int>((ref) => 0);
final semesterProvider = StateProvider<String>((ref) => "上");
final accountProvider = StateProvider<String>((ref) => "");
final pwdProvider = StateProvider<String>((ref) => "");
final teachWordViewProvider = StateProvider<int>((ref) => 0);
final userNameProvider = StateProvider<String>((ref) => "");
final totalWordCountProvider = StateProvider<int>((ref) => 186);
final learnedWordCountProvider = StateProvider<int>((ref) => 0);
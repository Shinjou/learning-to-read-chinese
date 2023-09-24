import 'package:flutter_riverpod/flutter_riverpod.dart';

final soundSpeedProvider = StateProvider<double>((ref) => 0.5);
final chuyinOnProvider = Provider((ref) => true);

final gradeProvider = StateProvider<int>((ref) => 1);
final publisherCodeProvider = StateProvider<int>((ref) => 0);
final accountProvider = StateProvider<String>((ref) => "");
final pwdProvider = StateProvider<String>((ref) => "");
final teachWordViewProvider = StateProvider<int>((ref) => 0);
final userNameProvider = StateProvider<String>((ref) => "");

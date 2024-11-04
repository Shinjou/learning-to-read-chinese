// lib/teach_word/services/word_service.dart

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';

class WordData {
  final bool isBpmf;
  final bool svgExists;
  final bool img1Exists;
  final bool img2Exists;
  final String svgData;
  final bool isValid;

  const WordData({
    this.isBpmf = false,
    this.svgExists = false,
    this.img1Exists = false,
    this.img2Exists = false,
    this.svgData = '',
    this.isValid = false,
  });
}

class WordService {
  static final WordService _instance = WordService._internal();
  
  factory WordService() {
    return _instance;
  }
  
  WordService._internal();

  // List of characters without SVG data
  static const List<String> noSvgList = [
    '吔', '姍', '媼', '嬤', '履', '搧', '枴', '椏', '欓', '汙',
    '溼', '漥', '痠', '礫', '粄', '粿', '綰', '蓆', '襬', '譟',
    '踖', '踧', '鎚', '鏗', '鏘', '陳', '颺', '齒'
  ];

  Future<WordData> getWordData(String word) async {
    try {
      // Check if word is in no SVG list
      final bool svgShouldExist = !noSvgList.contains(word);
      
      // Check BPMF status
      final bool isBpmf = await _checkIfBpmf(word);
      
      // Get SVG data if it should exist
      String svgData = '';
      bool svgExists = false;
      if (svgShouldExist) {
        svgData = await _loadSvgData(word);
        svgExists = svgData.isNotEmpty;
      }

      // Check image existence
      final bool img1Exists = await _checkImageExists(word, 1);
      final bool img2Exists = await _checkImageExists(word, 2);

      return WordData(
        isBpmf: isBpmf,
        svgExists: svgExists,
        img1Exists: img1Exists,
        img2Exists: img2Exists,
        svgData: svgData,
        isValid: true,
      );
    } catch (e) {
      debugPrint('Error getting word data for $word: $e');
      return const WordData(isValid: false);
    }
  }

  Future<bool> _checkIfBpmf(String word) async {
    try {
      await rootBundle.load('lib/assets/img/bopomo/$word.png');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _checkImageExists(String word, int index) async {
    try {
      await rootBundle.load('lib/assets/img/vocabulary/$word$index.webp');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String> _loadSvgData(String word) async {
    try {
      final String response = await rootBundle.loadString('lib/assets/svg/$word.json');
      return response.replaceAll("\"", "'");
    } catch (e) {
      debugPrint('Error loading SVG data for $word: $e');
      return '';
    }
  }

  Future<void> markWordAsLearned(WordStatus status) async {
    try {
      await WordStatusProvider().updateWordStatus(status: status);
    } catch (e) {
      debugPrint('Error marking word as learned: $e');
      rethrow;
    }
  }

  Future<bool> checkWordExists(String word) async {
    try {
      await rootBundle.load('lib/assets/svg/$word.json');
      return true;
    } catch (_) {
      return false;
    }
  }
}

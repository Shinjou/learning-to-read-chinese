import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PolyphonicDataModel {
  late Map<String, dynamic> polyphonicData;

  Future<void> loadPolyphonicData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/data_files/poyin_db.json');
      polyphonicData = json.decode(jsonString);
      debugPrint('DuoyinziView initialized successfully');
    } catch (e) {
      debugPrint('Failed to load polyphonic data: $e');
    }
  }    
}

import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/materials/material_model.dart';

class MaterialRepository {
  List<MaterialModel> getAllMaterials() {
    try {
      return materialsJsonMapper();
    } on FormatException catch (e) {
      debugPrint("JSON format error: $e");
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Parse JSON string to a list of MaterialModel objects
  List<MaterialModel> materialsJsonMapper() {
    // Sanitize the JSON string to handle special characters
    // String sanitizedJson = sanitizeJsonString(jsonString);
    Map<String, dynamic> jsonMap = jsonDecode('');

    List<MaterialModel> materials =
        (jsonMap['Materials']['M'] as List).map((materialJson) => MaterialModel.fromJson(materialJson)).toList();

    return materials;
  }

  // Function to sanitize JSON string by escaping problematic characters
  String sanitizeJsonString(String jsonString) {
    // ignore: unnecessary_string_escapes
    return jsonString.replaceAll('\"', '\\\"'); // Escape quotes
  }
}

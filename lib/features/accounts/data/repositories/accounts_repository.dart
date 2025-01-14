import 'dart:convert';

import 'package:ba3_bs_mobile/features/accounts/data/datasources/local/accounts_json.dart';
import 'package:flutter/foundation.dart';

import '../models/account_model.dart';

class AccountsRepository {
  List<AccountModel> getAllAccounts() {
    try {
      return accountsJsonMapper();
    } on FormatException catch (e) {
      debugPrint("JSON format error: $e");
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Parse JSON string to a list of MaterialModel objects
  List<AccountModel> accountsJsonMapper() {
    // Sanitize the JSON string to handle special characters
    // String sanitizedJson = sanitizeJsonString(jsonString);
    Map<String, dynamic> jsonMap = jsonDecode(accountsJson);

    List<AccountModel> accounts =
        (jsonMap['MainExp']['Export']['Accounts']['A'] as List).map((accountJson) => AccountModel.fromJson(accountJson)).toList();

    return accounts;
  }

  // Function to sanitize JSON string by escaping problematic characters
  String sanitizeJsonString(String jsonString) {
    //TODO:i change .replaceAll('\"', '\\\"') to .replaceAll('"', '\\"')
    return jsonString.replaceAll('"', '\\"'); // Escape quotes
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:medisafe/models/category_model.dart';

class CategoryRepository {
  Future<List<Category>> fetchCategories() async {
    try {
      // Load JSON data from assets
      final String response =
          await rootBundle.loadString('assets/categories.json');
      final List<dynamic> data = json.decode(response);

      // Map JSON data to Category model
      return data.map((item) => Category.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to load categories from JSON: $e");
    }
  }
}

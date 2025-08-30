import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CategoryProvider() {
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Updated query without .execute()
      final response = await Supabase.instance.client
          .from('anxiety_categories')
          .select();

      // The response is now directly the data (List<dynamic> or Map<String, dynamic>)
      if (response != null) {
        _categories = List<Map<String, dynamic>>.from(response);
      } else {
        _categories = [];
      }

      _errorMessage = null; // Clear any previous error
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error fetching categories: $e';
      _isLoading = false;
      notifyListeners();
      print('Error fetching categories: $e');
    }
  }

  Future<void> refreshCategories() async {
    await _fetchCategories();
  }
}
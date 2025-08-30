import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NegThoughtsProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _negThoughts = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> get negThoughts => _negThoughts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NegThoughtsProvider() {
    _fetchNegThoughts();
  }

  Future<void> _fetchNegThoughts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await Supabase.instance.client
          .from('negative_thoughts')
          .select();
      _negThoughts.clear();
      if (response != null) {
        _negThoughts.addAll(List<Map<String, dynamic>>.from(response));
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load negative thoughts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNegThoughts() async {
    await _fetchNegThoughts();
  }
}
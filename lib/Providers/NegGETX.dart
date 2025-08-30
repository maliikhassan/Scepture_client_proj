import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NegThoughtsController extends GetxController {
  final RxList<Map<String, dynamic>> _negThoughts = <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = true.obs;
  final RxString _errorMessage = RxString('.');

  List<Map<String, dynamic>> get negThoughts => _negThoughts;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage?.value;

  @override
  void onInit() {
    super.onInit();
    _fetchNegThoughts();
  }

  Future<void> _fetchNegThoughts() async {
    _isLoading.value = true;
    _errorMessage.value = 'null';
    try {
      final response = await Supabase.instance.client.from('negative_thoughts').select();
      _negThoughts.clear();
      if (response != null) {
        _negThoughts.addAll(List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      _errorMessage?.value = 'Failed to load negative thoughts: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshNegThoughts() async {
    await _fetchNegThoughts();
  }

  // Method to find a negThought by text
  Map<String, dynamic>? findNegThought(String thoughtText) {
    return _negThoughts.firstWhere(
      (thought) => thought['thought_text']?.toLowerCase() == thoughtText.toLowerCase(),
      orElse: () => {},
    ).isNotEmpty
        ? _negThoughts.firstWhere(
            (thought) => thought['thought_text']?.toLowerCase() == thoughtText.toLowerCase())
        : null;
  }
}
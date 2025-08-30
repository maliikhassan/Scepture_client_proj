import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  var userData = Rxn<Map<String, dynamic>>();
  
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyData();
  }

  Future<void> fetchMyData() async {
    try {
      isLoading.value = true;
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('users')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .single();
      userData.value = response;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Error loading user data: $e');
    }
  }

  Future<void> refreshUserData() async {
    await fetchMyData();
  }

  Future<bool> updateToPremium(String subscriptionType) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      DateTime expiryDate;
      if (subscriptionType == 'yearly') {
        expiryDate = DateTime.now().add(Duration(days: 365));
      } else {
        expiryDate = DateTime.now().add(Duration(days: 30));
      }
      await _supabase.from('users').update({
        'is_premium': true,
        'subscription_type': subscriptionType,
        'subscription_expires_at': expiryDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);
      await refreshUserData();
      return true;
    } catch (e) {
      print('Error updating user to premium: $e');
      return false;
    }
  }

  bool get isPremium {
    final data = userData.value;
    if (data == null) return false;
    final isPremium = data['is_premium'] ?? false;
    final expiresAt = data['subscription_expires_at'];
    if (!isPremium || expiresAt == null) return false;
    final expiryDate = DateTime.parse(expiresAt);
    return DateTime.now().isBefore(expiryDate);
  }

  DateTime? get subscriptionExpiryDate {
    final data = userData.value;
    if (data == null) return null;
    final expiresAt = data['subscription_expires_at'];
    if (expiresAt == null) return null;
    return DateTime.parse(expiresAt);
  }

  String? get subscriptionType {
    final data = userData.value;
    if (data == null) return null;
    return data['subscription_type'];
  }

  String get subscriptionExpiryText {
    final expiryDate = subscriptionExpiryDate;
    if (expiryDate == null) return '';
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    if (difference.inDays > 0) {
      return 'Expires in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'Expires in ${difference.inHours} hours';
    } else {
      return 'Expired';
    }
  }
}
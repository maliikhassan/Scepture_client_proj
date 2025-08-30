import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  UserProvider() {
    _fetchMyData();
  }

  Future<void> _fetchMyData() async {
    try {
      _isLoading = true;
      notifyListeners();
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('users')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .single();
      _userData = response;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading user data: $e');
    }
  }

  // Function to refresh user data
  Future<void> refreshUserData() async {
    await _fetchMyData();
  }

  // Function to update user to premium
  Future<bool> updateToPremium(String subscriptionType) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // Calculate subscription expiry date
      DateTime expiryDate;
      if (subscriptionType == 'yearly') {
        expiryDate = DateTime.now().add(Duration(days: 365));
      } else {
        expiryDate = DateTime.now().add(Duration(days: 30));
      }

      // Update user in database
      await _supabase.from('users').update({
        'is_premium': true,
        'subscription_type': subscriptionType,
        'subscription_expires_at': expiryDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      // Refresh user data to reflect changes
      await refreshUserData();
      
      return true;
    } catch (e) {
      print('Error updating user to premium: $e');
      return false;
    }
  }

  // Check if user is premium and subscription is still valid
  bool get isPremium {
    if (_userData == null) return false;
    
    final isPremium = _userData!['is_premium'] ?? false;
    final expiresAt = _userData!['subscription_expires_at'];
    
    if (!isPremium || expiresAt == null) return false;
    
    final expiryDate = DateTime.parse(expiresAt);
    return DateTime.now().isBefore(expiryDate);
  }

  // Get subscription expiry date
  DateTime? get subscriptionExpiryDate {
    if (_userData == null) return null;
    
    final expiresAt = _userData!['subscription_expires_at'];
    if (expiresAt == null) return null;
    
    return DateTime.parse(expiresAt);
  }

  // Get subscription type
  String? get subscriptionType {
    if (_userData == null) return null;
    return _userData!['subscription_type'];
  }

  // Get formatted expiry date string
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
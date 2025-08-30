import 'package:get/get.dart';
import 'package:scapture/UI/HomePage.dart';
import 'package:scapture/UI/LoginScreen.dart';
import 'package:scapture/UI/onBoardingScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Database {
  final SupabaseClient _supabase = Supabase.instance.client;
  void isLogin() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      Get.off(OnboardingScreen());
    } else {
      Get.off(HomeScreen());
    }
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      Get.snackbar("Success", 'Successfully Signout');
      Get.off(LoginPage());
    } catch (e) {
      Get.snackbar("Failed", e.toString());
    }
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // Sign up user with Supabase Auth
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to create user');
    }

    // Insert user data into the users table
    await _supabase.from('users').insert({
      'user_id': response.user!.id,
      'email': email,
      'full_name': fullName,
    });
  }

  Future<void> login({required String email, required String password}) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed: Invalid email or password');
    }
  }

  Future<List<Map<String, dynamic>>> fetchNegativeThoughts(String anxId) async {
    try {
      final response = await _supabase
          .from('negative_thoughts')
          .select()
          .eq('anx_id', anxId);

      if (response != null) {
        return List<Map<String, dynamic>>.from(response);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching negative thoughts: $e');
      return [];
    }
  }
  Future<List<Map<String, dynamic>>> fetchScaptures(String negId) async {
    try {
      final response = await _supabase
          .from('scriptures')
          .select()
          .eq('neg_thought_id', negId);

      if (response != null) {
        return List<Map<String, dynamic>>.from(response);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching scaptures: $e');
      return [];
    }
  }
}

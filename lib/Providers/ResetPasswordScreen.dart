import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scapture/UI/LoginScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  void signOut() async {
    await Supabase.instance.client.auth.signOut();
    Get.off(LoginPage());
  }

  void _resetPassword() async {
    final newPassword = _passwordController.text.trim();

    final res = await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    print("Ok Updated ");

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Password updated successfully!")));
      //Navigator.pop(context); // or navigate to login
     
    }
    signOut();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Set New Password",
            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              "Create a strong password to secure your account",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Modern TextField
            TextField(
              controller: _passwordController,
              
              obscureText: true,
              decoration: InputDecoration(
                
                hintText: "Enter new password",
                filled: true,
                fillColor: Colors.black,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(width: 2,color: Colors.black)
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(width: 2,color: Colors.black)
                ), 
              ),
              style: TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 30),
            
            // Full-width button
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  "Reset Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
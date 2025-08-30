import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:scapture/UI/LoginScreen.dart';
import 'package:scapture/UI/SignUpScreen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top image
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0A194C), // Deep blue background
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  height: double.infinity,
                  "assets/images/onboarding.jpg",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Title and description
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  width: double.infinity,
                  color: Color(0xFF001B4F),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 3,
                    children: [
                      const Text(
                        "Turn your Struggles into Victory",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEFBF04), // Yellow color
                        ),
                      ),
                      Row(
                        children: [
                          Spacer(),
                          const Text(
                            "1 Corinthians 15:57",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                              color: Colors.white,
                              
                            ),
                          ),
                          SizedBox(width: 30,)
                        ],
                      ),
                    ],
                  ),
                ),
            
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(20),
                  child: const Text(
                    "Conquer anxiety with faith-powered tools. Learn to identify anxious thoughts, combat them with scripture, and grow stronger every day through God's truth.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
                //const Spacer(),
                // Buttons
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            Get.to(()=>LoginPage());
                          },
                          child: const Text("Login",style: TextStyle(color: Colors.white,fontSize: 19,fontWeight: FontWeight.bold),),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black,width: 3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            Get.to(()=>SignUpPage());
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(color: Colors.black,fontSize: 19,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

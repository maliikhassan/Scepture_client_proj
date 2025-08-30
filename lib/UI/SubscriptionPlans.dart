import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
// Import your UserProvider here
// import 'user_provider.dart';

// 2. Stripe Payment Service (Flutter Only)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scapture/Providers/UserProvider.dart';

class StripePaymentService {
  static const String _secretKey = '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'; // Replace with your secret key
  
  static Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency,
          'description': description,
          'automatic_payment_methods[enabled]': 'true',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  static Future<bool> processPayment({
    required String amount,
    required String currency,
    required String description,
  }) async {
    try {
      // Create payment intent
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        currency: currency,
        description: description,
      );

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'Your App Name',
          customFlow: false,
          allowsDelayedPaymentMethods: false,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      return true; // Payment successful
    } catch (e) {
      print('Payment error: $e');
      rethrow;
    }
  }
}

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int selectedPlan = 0; // 0 for Annual, 1 for Monthly
  bool isProcessingPayment = false;

  Future<void> _handlePayment() async {
    if (isProcessingPayment) return;
    
    setState(() {
      isProcessingPayment = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Get plan details
      String planType = selectedPlan == 0 ? 'yearly' : 'monthly';
      String planDisplayName = selectedPlan == 0 ? 'Annual' : 'Monthly';
      String amount = selectedPlan == 0 ? '10788' : '899'; // Amount in cents
      String priceDisplay = selectedPlan == 0 ? '\$107.88' : '\$8.99';
      
      // Process payment
      bool paymentSuccess = await StripePaymentService.processPayment(
        amount: amount,
        currency: 'usd',
        description: '$planDisplayName Subscription Plan',
      );

      if (paymentSuccess) {
        // Update user to premium after successful payment
        bool updateSuccess = await userProvider.updateToPremium(planType);
        
        if (updateSuccess) {
          _showSuccessDialog(planDisplayName, priceDisplay);
        } else {
          _showErrorDialog('Payment successful but failed to update subscription. Please contact support.');
        }
      }
      
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('canceled')) {
        // User canceled payment - don't show error
        print('Payment canceled by user');
      } else {
        _showErrorDialog(errorMessage);
      }
    } finally {
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  void _showSuccessDialog(String planType, String price) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Your $planType subscription for $price has been activated successfully. You are now a premium user!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  //Navigator.of(context).pop(); // Go back to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Continue'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Payment Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'There was an error processing your payment. Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Try Again'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPremiumUserCard() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green[50],
            border: Border.all(color: Colors.green[300]!, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.star,
                color: Colors.green[600],
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'You are a Premium User',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 8),
              Text(
                userProvider.subscriptionExpiryText,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Subscription Type: ${userProvider.subscriptionType?.toUpperCase() ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[600],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Your subscription will be available again after the current period ends.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              // Check if user is premium
              if (userProvider.isPremium) {
                return Column(
                  children: [
                    // Header Section
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Premium Active',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'You are currently enjoying all premium features!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 15),
                          // Illustration
                          Image.asset("assets/images/subscriptionIllustration.png", height: 150),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    // Premium User Card
                    _buildPremiumUserCard(),
                  ],
                );
              }

              // Regular subscription screen for non-premium users
              return Column(
                children: [
                  // Header Section
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Free Limit Exceeded',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Unlock all the power of this app and enjoy\ndigital experience like never before!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 15),
                        // Illustration
                        Image.asset("assets/images/subscriptionIllustration.png", height: 150),
                      ],
                    ),
                  ),
                  // Subscription Plans Section
                  Container(
                    child: Column(
                      children: [
                        // Annual Plan
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPlan = 0;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: selectedPlan == 0 ? Colors.grey[100] : Colors.white,
                              border: Border.all(
                                color: selectedPlan == 0 ? Colors.blue[600]! : Colors.grey[300]!,
                                width: selectedPlan == 0 ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Annual',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green[600],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Best Value',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'First 30 days free - Then \$107.88/Year',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                if (selectedPlan == 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.blue[600],
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Monthly Plan
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPlan = 1;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: selectedPlan == 1 ? Colors.grey[100] : Colors.white,
                              border: Border.all(
                                color: selectedPlan == 1 ? Colors.blue[600]! : Colors.grey[300]!,
                                width: selectedPlan == 1 ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Monthly',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'First 7 days free - Then \$8.99/Month',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                if (selectedPlan == 1)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.blue[600],
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        // Terms and Conditions
                        Text(
                          'By placing this order, you agree to the Terms of Service and Privacy Policy. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Continue Button with Stripe Payment
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: isProcessingPayment ? null : _handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isProcessingPayment ? Colors.grey : Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isProcessingPayment
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Processing Payment...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class PaymentScreen extends StatefulWidget {
  final String planType;
  final String price;
  final String orderId;

  const PaymentScreen({
    Key? key,
    required this.planType,
    required this.price,
    required this.orderId,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedPaymentMethod = -1; // -1 for none selected
  int countdown = 15 * 60; // 15 minutes in seconds
  bool isProcessingPayment = false;
  
  // Payment client for advanced control
  late final Pay _payClient;
  StreamSubscription<dynamic>? _paymentResultSubscription;
  
  // Google Pay configuration with DIRECT integration
  String get googlePayConfigString {
    // Extract numeric value from price string
    String cleanPrice = widget.price.replaceAll(RegExp(r'[^\d.]'), '');
    
    return '''
{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "parameters": {
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "allowedCardNetworks": ["VISA", "MASTERCARD", "AMEX", "DISCOVER"]
        },
        "tokenizationSpecification": {
          "type": "DIRECT",
          "parameters": {
            "protocolVersion": "ECv2",
            "publicKey": "BGbXsgfD98VfP4nYfX7RrO+8IgYBg5nsK4FkYAnhhdxeu+R1f/wnZ4Ec7CNBdpW1rNF6upS/ln2BR+jN29CNwtA="
          }
        }
      }
    ],
    "merchantInfo": {
      "merchantId": "BCR2DN7TZD7PBTSY",
      "merchantName": "Admin"
    },
    "transactionInfo": {
      "totalPriceStatus": "FINAL",
      "totalPrice": "$cleanPrice",
      "currencyCode": "USD",
      "countryCode": "US"
    },
    "shippingAddressRequired": false,
    "emailRequired": false
  }
}
''';
  }

  @override
  void initState() {
    super.initState();
    startCountdown();
    _initializePayClient();
    _setupPaymentResultListener();
  }

  void _initializePayClient() {
    _payClient = Pay({
      PayProvider.google_pay: PaymentConfiguration.fromJsonString(googlePayConfigString),
    });
  }

  void _setupPaymentResultListener() {
    // For Android Google Pay results
    const eventChannel = EventChannel('plugins.flutter.io/pay/payment_result');
    _paymentResultSubscription = eventChannel
        .receiveBroadcastStream()
        .map((result) => jsonDecode(result as String) as Map<String, dynamic>)
        .listen((result) {
          _handlePaymentResult(result);
        }, onError: (error) {
          _handlePaymentError(error);
        });
  }

  void startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && countdown > 0) {
        setState(() {
          countdown--;
        });
        startCountdown();
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  List<PaymentItem> get _paymentItems {
    // Extract numeric value from price string (assuming format like "$9.99" or "9.99")
    String cleanPrice = widget.price.replaceAll(RegExp(r'[^\d.]'), '');
    
    return [
      PaymentItem(
        label: widget.planType,
        amount: cleanPrice,
        status: PaymentItemStatus.final_price,
      ),
    ];
  }

  Future<void> _processGooglePayPayment() async {
    if (isProcessingPayment) return;
    
    setState(() {
      isProcessingPayment = true;
    });

    try {
      // Check if user can pay with Google Pay
      final bool canPay = await _payClient.userCanPay(PayProvider.google_pay);
      
      if (!canPay) {
        _showErrorMessage('Google Pay is not available on this device');
        return;
      }

      // Show Google Pay payment sheet
      await _payClient.showPaymentSelector(
        PayProvider.google_pay,
        _paymentItems,
      );
      
      // Result will be handled in the event channel listener
      
    } catch (error) {
      _handlePaymentError(error);
    } finally {
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  void _handlePaymentResult(Map<String, dynamic> result) {
    setState(() {
      isProcessingPayment = false;
    });

    print('Payment Result: $result');
    
    // Extract payment token for direct integration
    if (result.containsKey('paymentMethodData')) {
      final paymentMethodData = result['paymentMethodData'];
      
      if (paymentMethodData.containsKey('tokenizationData')) {
        final tokenizationData = paymentMethodData['tokenizationData'];
        final String paymentToken = tokenizationData['token'];
        
        // For direct integration, you get the encrypted payment data
        print('Payment Token: $paymentToken');
        _processDirectPayment(paymentToken, paymentMethodData);
      } else {
        _showErrorMessage('Payment token not found');
      }
    } else {
      _showErrorMessage('Payment data not found');
    }
  }

  void _handlePaymentError(dynamic error) {
    setState(() {
      isProcessingPayment = false;
    });

    print('Payment Error: $error');
    
    String errorMessage = 'Payment failed. Please try again.';
    if (error.toString().contains('CANCELED')) {
      errorMessage = 'Payment was cancelled.';
    } else if (error.toString().contains('DEVELOPER_ERROR')) {
      errorMessage = 'Payment configuration error. Please check your setup.';
    } else if (error.toString().contains('INTERNAL_ERROR')) {
      errorMessage = 'Google Pay internal error. Please try again.';
    }
    
    _showErrorMessage(errorMessage);
  }

  Future<void> _processDirectPayment(String paymentToken, Map<String, dynamic> paymentMethodData) async {
    try {
      // For direct integration, you need to:
      // 1. Decrypt the payment token using your private key
      // 2. Extract card details
      // 3. Process payment with your payment processor
      
      print('Processing direct payment...');
      print('Payment Token: $paymentToken');
      print('Payment Method Data: $paymentMethodData');
      
      // TODO: Implement your direct payment processing logic here
      /*
      Example steps for direct integration:
      
      1. Send the encrypted payment token to your server
      2. Server decrypts the token using your private key
      3. Server processes the payment with your payment processor
      4. Return success/failure result to the app
      
      final response = await http.post(
        Uri.parse('https://your-server.com/process-direct-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'encrypted_payment_token': paymentToken,
          'payment_method_data': paymentMethodData,
          'order_id': widget.orderId,
          'amount': widget.price,
          'plan_type': widget.planType,
        }),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          _showSuccessMessage('Payment processed successfully!');
          Navigator.pop(context, true);
        } else {
          _showErrorMessage('Payment failed: ${result['error']}');
        }
      } else {
        _showErrorMessage('Payment processing failed.');
      }
      */
      
      // For demo purposes, simulate successful payment
      _showSuccessMessage('Payment token received. Processing...');
      
      // Simulate server processing
      await Future.delayed(Duration(seconds: 2));
      
      _showSuccessMessage('Payment completed successfully!');
      Navigator.pop(context, true);
      
    } catch (e) {
      print('Direct payment processing error: $e');
      _showErrorMessage('Payment processing failed. Please try again.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleContinuePressed() async {
    if (selectedPaymentMethod == -1) return;
    
    if (selectedPaymentMethod == 0) {
      // Google Pay selected
      await _processGooglePayPayment();
    } else if (selectedPaymentMethod == 1) {
      // Apple Pay selected
      _showErrorMessage('Apple Pay integration not implemented yet');
      // TODO: Implement Apple Pay integration
    }
  }

  @override
  void dispose() {
    _paymentResultSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order ID',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.orderId,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Total Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.price,
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  
                  // Payment Method Title
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Google Pay Option with availability check
                  FutureBuilder<bool>(
                    future: _payClient.userCanPay(PayProvider.google_pay),
                    builder: (context, snapshot) {
                      bool isGooglePayAvailable = snapshot.data ?? false;
                      
                      return GestureDetector(
                        onTap: isGooglePayAvailable ? () {
                          setState(() {
                            selectedPaymentMethod = 0;
                          });
                        } : null,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isGooglePayAvailable ? Color(0xFF2A2A3E) : Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedPaymentMethod == 0 && isGooglePayAvailable
                                  ? Colors.blue 
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isGooglePayAvailable ? Colors.white : Colors.grey[700],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/google_pay.png',
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.payment, 
                                        color: isGooglePayAvailable ? Colors.blue : Colors.grey,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Google Pay',
                                    style: TextStyle(
                                      color: isGooglePayAvailable ? Colors.white : Colors.grey[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (isGooglePayAvailable)
                                    Text(
                                      'Direct Integration',
                                      style: TextStyle(
                                        color: Colors.green[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              if (!isGooglePayAvailable) ...[
                                SizedBox(width: 8),
                                Text(
                                  '(Not Available)',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              Spacer(),
                              if (isGooglePayAvailable)
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[400],
                                  size: 16,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Apple Pay Option (disabled for now)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPaymentMethod = 1;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A3E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedPaymentMethod == 1 
                              ? Colors.blue 
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/apple_pay.png',
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.apple, color: Colors.white);
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Apple Pay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Spacer(),
                  
                  // Countdown Timer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Complete your payment in',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          formatTime(countdown),
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
          
          // Continue Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: (selectedPaymentMethod != -1 && !isProcessingPayment) 
                  ? _handleContinuePressed 
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isProcessingPayment 
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Processing...',
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
      ),
    );
  }
}
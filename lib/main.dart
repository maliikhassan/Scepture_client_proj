import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:scapture/Providers/CategoryProvider.dart';
import 'package:scapture/Providers/NegthoughtsProvider.dart';
import 'package:scapture/Providers/ResetPasswordScreen.dart';
import 'package:scapture/Providers/UserGETXProvider.dart';
import 'package:scapture/Providers/UserProvider.dart';
import 'package:scapture/Providers/router.dart';
import 'package:scapture/UI/SplashScreen.dart';
import 'package:scapture/UI/gameScreen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services with error handling
  Widget? initialScreen = SplashScreen();

  try {
    // Awesome Notifications setup with initial action handling
    await _initializeNotifications();
    final initialAction =
        await AwesomeNotifications().getInitialNotificationAction();
    if (initialAction?.payload != null &&
        initialAction!.payload!['re_id'] != null) {
      initialScreen =
          ScepterHomeScreen(); // Navigate to ScepterHomeScreen on notification tap
    }

    // Stripe configuration
    await _configureStripe();

    // Supabase initialization
    await _initializeSupabase();
    print("Supabase is initialized");
  } catch (e) {
    print('Error during initialization: $e');
    // Fallback to SplashScreen on error
  }
  Get.put(UserController());

  // Run the app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => NegThoughtsProvider()),
      ],
      child: MyApp(initialScreen: initialScreen),
    ),
  );
}

// Helper function to initialize Awesome Notifications
Future<void> _initializeNotifications() async {
  await AwesomeNotifications().initialize(
    null, // No default icon, configure if needed
    [
      NotificationChannel(
        channelKey: 'reminder_channel', // Match with SetReminderScreen
        channelName: 'Reminder Notifications',
        channelDescription: 'Notification channel for reminders',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
      ),
    ],
    debug: true,
  );
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
}

// Helper function to configure Stripe
Future<void> _configureStripe() async {
  Stripe.publishableKey =
      'pk_test_51RjwRz4Z0zyymjpgUr7gizeuijKvEXWx96rfp7APyCAqLFRn2q5j1sRY0sEnv6TtfccbhQdSKwrIZ8W8KZXe8PI2001PT6zdIl'; // Replace with your publishable key
  Stripe.merchantIdentifier = 'merchant.your.app.identifier'; // For Apple Pay
}

// Helper function to initialize Supabase
Future<void> _initializeSupabase() async {
  await Supabase.initialize(
    url: "https://jixxtzavfnetumbuzzjf.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppeHh0emF2Zm5ldHVtYnV6empmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4MTkxMTEsImV4cCI6MjA2MzM5NTExMX0.UP99SAEb9V7-ADAPdk1zfFdbY-HqbfyGtsfEw7FIseQ",
  );
}

// Placeholder MyApp widget (implement based on your app structure)
class MyApp extends StatefulWidget {
  final Widget? initialScreen;

  const MyApp({super.key, this.initialScreen});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 late final StreamSubscription<Uri?> _sub;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _handleInitialLink(); // Handle cold start links
  }

  void _handleIncomingLinks() {
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.toString().contains("reset-password")) {
        Get.off(() => ResetPasswordScreen());
      }
    });
  }

  Future<void> _handleInitialLink() async {
  try {
    final Uri? initialUri = await _appLinks.getInitialLink(); // ✅ Correct method
    if (initialUri != null &&
        initialUri.toString().contains("reset-password")) {
      Get.off(() => ResetPasswordScreen());
    }
  } catch (e) {
    print("❌ Failed to handle initial link: $e");
  }
}

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: widget.initialScreen,
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      // Add other MaterialApp configurations as needed
    );
  }
}
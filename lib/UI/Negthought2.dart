import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scapture/Providers/NegGETX.dart'; // Adjust to match your NegThoughtsController file
import 'package:scapture/Providers/UserGETXProvider.dart';
import 'package:scapture/UI/Scaptures.dart';
import 'package:scapture/UI/SubscriptionPlans.dart';

class NegThought2Screen extends StatefulWidget {
  final String negThought;

  const NegThought2Screen({super.key, required this.negThought});

  @override
  _NegThought2ScreenState createState() => _NegThought2ScreenState();
}

class _NegThought2ScreenState extends State<NegThought2Screen> {
  late final NegThoughtsController _negThoughtsController;
  String? _negId; // To store the matched neg_id
  bool _isMatching = true; // Loading state for matching

  @override
  void initState() {
    super.initState();
    // Ensure UserController is initialized globally or here
    final userConroller=Get.find<UserController>;
    // Refresh user data if needed
    

    _negThoughtsController = Get.put(NegThoughtsController()); // Initialize controller
    _matchThought();
  }

  Future<void> _matchThought() async {
    setState(() => _isMatching = true);
    // Wait for negThoughts to be fetched if not yet loaded
    while (_negThoughtsController.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    final matchedThought = _negThoughtsController.negThoughts.firstWhere(
      (thought) => thought['thought_text']?.toLowerCase() == widget.negThought.toLowerCase(),
      orElse: () => {},
    );
    if (matchedThought.isNotEmpty) {
      _negId = matchedThought['id']?.toString(); // Ensure _negId is a String if required
    } else {
      _negId = null; // Explicitly set to null if no match
    }
    setState(() => _isMatching = false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _waitForUserData(), // Wait for UserController to initialize
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        } else {
          final UserController userController = Get.find<UserController>(); // Use existing instance
          final bool? isPremium = userController.userData.value?['is_premium'];
          debugPrint('isPremium: $isPremium');

          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  // Name and Description (using the input negThought)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.negThought, // Display the input negThought as title
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Description for ${widget.negThought}', // Placeholder, replace with actual description if available
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  // List of Negative Thoughts (single thought in this case)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: _isMatching
                          ? const Center(child: CircularProgressIndicator(color: Colors.black))
                          : _negId == null
                              ? const Center(
                                  child: Text(
                                    'No matching thought found',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: 1, // Only one thought
                                  itemBuilder: (context, index) {
                                    return Card(
                                      elevation: 4,
                                      color: Colors.grey[900],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          widget.negThought, // Display the input negThought
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        trailing: isPremium == true
                                            ? const Icon(
                                                Icons.chevron_right,
                                                color: Colors.white70,
                                              )
                                            : const Icon(
                                                Icons.lock,
                                                color: Colors.white70,
                                              ),
                                        onTap: () {
                                          if (isPremium == true && _negId != null) {
                                            Get.to(
                                              ScapturesScreen(
                                                negId: _negId!, // Safe to use ! since _negId is checked
                                                Neg_name: widget.negThought, // Use the input negThought
                                              ),
                                            );
                                          } else {
                                            Get.to(() => SubscriptionScreen());
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _waitForUserData() async {
    final userController = Get.find<UserController>();
    while (userController.isLoading.value || userController.userData.value == null) {
      await Future.delayed(const Duration(milliseconds: 100)); // Poll until data is ready
    }
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scapture/Database/Database.dart';
import 'package:scapture/Providers/UserGETXProvider.dart';
import 'package:scapture/UI/Scaptures.dart';
import 'package:scapture/UI/SubscriptionPlans.dart';

class NegThoughtScreen extends StatefulWidget {
  final String anxId;
  final String name;
  final String description;

  const NegThoughtScreen({
    super.key,
    required this.anxId,
    required this.name,
    required this.description,
  });

  @override
  _NegThoughtScreenState createState() => _NegThoughtScreenState();
}

class _NegThoughtScreenState extends State<NegThoughtScreen> {
  final userController = Get.put(UserController());
  late final Database _database;
  List<Map<String, dynamic>> _thoughts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _database = Database();
    _loadThoughts();
  }

  Future<void> _loadThoughts() async {
    setState(() => _isLoading = true);
    final thoughts = await _database.fetchNegativeThoughts(widget.anxId);
    setState(() {
      _thoughts = thoughts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = userController.userData.value;
    final bool? isPremium = userData?['is_premium'];
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
            // Name and Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // List of Negative Thoughts
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                        : _thoughts.isEmpty
                        ? const Center(
                          child: Text(
                            'No negative thoughts found',
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                        : ListView.builder(
                          itemCount: _thoughts.length,
                          itemBuilder: (context, index) {
                            final thought = _thoughts[index];
                            return Card(
                              elevation: 4,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.black, // border color
                                  width: 2, // border width
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  thought['thought_text'] ?? 'Unknown Thought',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing:
                                    isPremium == true
                                        ? const Icon(
                                          Icons.chevron_right,
                                          color: Colors.white70,
                                        )
                                        : const Icon(
                                          Icons.lock,
                                          color: Colors.white70,
                                        ),
                                onTap: () {
                                  if (isPremium == true) {
                                    Get.to(
                                      ScapturesScreen(
                                        negId: thought['id'],
                                        Neg_name: thought['thought_text'],
                                      ),
                                    );
                                  } else {
                                    Get.to(SubscriptionScreen());
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
}

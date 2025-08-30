import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:scapture/Providers/CategoryProvider.dart';
import 'package:scapture/UI/NegThoughtsScreen.dart';
import 'package:scapture/UI/UploadMyData.dart';

class AnxietyCategoryScreen extends StatelessWidget {
  const AnxietyCategoryScreen({super.key});

  // Define colors for each category
  final List<Color> categoryColors = const [
    Colors.black,           // Social Anxiety
    Color(0xFFEFBF04),     // General Worry
    Color(0xFF4ECDC4),     // Fear of Failure
    Colors.black,           // Panic Attacks
    Color(0xFFEFBF04),     // Fear of Failure (repeat)
    Color(0xFF4ECDC4),     // Panic Attacks (repeat)
    Colors.black,           // Health Anxiety
  ];

  // Define counts for each category
  final List<String> categoryCounts = const [
    '30+',
    '80+',
    '23+',
    '67+',
    '23+',
    '67+',
    '56+',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
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
                  const SizedBox(width: 10),
                  const Text(
                    'Anxiety Categories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Categories List
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFEFBF04),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                ),
                child: Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    if (categoryProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      );
                    }

                    if (categoryProvider.categories.isEmpty) {
                      return const Center(
                        child: Text(
                          'No categories found',
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: categoryProvider.categories.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final category = categoryProvider.categories[index];
                        final color = categoryColors[index % categoryColors.length];
                        final count = categoryCounts[index % categoryCounts.length];
                        final isBlack = color == Colors.black;
                        
                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              NegThoughtScreen(
                                anxId: category['id'], 
                                name: category['name'], 
                                description: category['description']
                              )
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 3),
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Number circle
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isBlack ? Colors.white : Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: isBlack ? Colors.black : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Category info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category['name'] ?? 'Unknown Category',
                                        style: TextStyle(
                                          color: isBlack ? Colors.white : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        category['description'] ?? '',
                                        style: TextStyle(
                                          color: isBlack ? Colors.white70 : Colors.black87,
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Count badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isBlack ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    count,
                                    style: TextStyle(
                                      color: isBlack ? Colors.white : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
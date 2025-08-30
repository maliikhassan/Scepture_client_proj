import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NegativeThoughtsInserter {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> insertNegativeThoughts(String categoryId) async {
    try {
      final thoughts = [
        "Public transportation, Crowds or enclosed spaces, Being alone outside the home",
        "What if I have a panic attack and can’t get out?",
        "I can’t be too far from home—it’s not safe.",
        "If something happens to me, no one will be able to help.",
        "Crowded places make me feel trapped.",
        "I feel better when I stay inside.",
        "What if I pass out in front of everyone?",
        "I can't be alone out there—what if I need someone?",
        "That place is too far. What if I can’t make it back?",
        "I don’t trust my body—I might lose control.",
        "It’s too unpredictable out there. Anything could happen.",
        "Even thinking about leaving makes my chest tighten.",
        "I need to know there’s an exit nearby.",
        "I should only go out if someone is with me.",
        "What if I get stuck in traffic and can’t escape?",
        "It’s safer not to go at all.",
        "Being away from home makes me feel exposed.",
        "The world just feels too overwhelming.",
        "I hate feeling watched when I’m struggling.",
        "No one understands how scary this is.",
        "I wish I could just go out without fear.",
      ];

      final List<Map<String, dynamic>> thoughtsToInsert =
          thoughts
              .map((thought) => {'anx_id': categoryId, 'thought_text': thought})
              .toList();

      await _supabase.from('negative_thoughts').insert(thoughtsToInsert);
    } catch (e) {
      print('Error inserting negative thoughts: $e');
    }
  }
}

class UploadMyDataScreen extends StatelessWidget {
  final String categoryId;

  const UploadMyDataScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final inserter = NegativeThoughtsInserter();

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
                    'Upload My Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Centered button to insert data
            Expanded(
              child: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await inserter.insertNegativeThoughts(categoryId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data inserted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Insert Negative Thoughts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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

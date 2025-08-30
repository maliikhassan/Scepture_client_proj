import 'package:flutter/material.dart';
import 'package:scapture/Database/Database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScapturesScreen extends StatefulWidget {
  final String negId;
  final String Neg_name;
  const ScapturesScreen({
    super.key,
    required this.negId,
    required this.Neg_name,
  });

  @override
  _ScapturesScreenState createState() => _ScapturesScreenState();
}

class _ScapturesScreenState extends State<ScapturesScreen> {
  late final Database _database;
  List<Map<String, dynamic>> _scaptures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _database = Database();
    _loadScaptures();
  }

  Future<void> _loadScaptures() async {
    setState(() => _isLoading = true);
    final scaptures = await _database.fetchScaptures(widget.negId);
    setState(() {
      _scaptures = scaptures;
      _isLoading = false;
    });
  }

  Future<void> _uploadScapture() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('scriptures').insert({
        'neg_thought_id': widget.negId,
        'verse_text':
            'The Lord is on my side; I will not fear: what can man do unto me?',
        'verse_reference': 'Psalm 118:6 (KJV)',
      });
      await _loadScaptures(); // Refresh the list after upload
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scapture uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading scapture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Solution',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Negative Thought and Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.Neg_name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // List of Scaptures
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFEFBF04),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      )
                    else if (_scaptures.isEmpty)
                      const Center(
                        child: Text(
                          'No scaptures found',
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: _scaptures.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final scapture = _scaptures[index];
                            final colors = [
                              Colors.black,           // Black
                              Color(0xFFEFBF04),     // Golden Yellow
                              Color(0xFF4ECDC4),     // Teal
                              Colors.black,           // Black
                              Color(0xFFEFBF04),     // Golden Yellow
                            ];
                            final color = colors[index % colors.length];
                            final isBlack = color == Colors.black;
                            
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 3),
                                color: color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    scapture['verse_text'] ?? 'Unknown Verse',
                                    style: TextStyle(
                                      color: isBlack ? Colors.white : Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      scapture['verse_reference'] ?? '',
                                      style: TextStyle(
                                        color: isBlack ? Colors.white70 : Colors.black87,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
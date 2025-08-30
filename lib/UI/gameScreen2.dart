// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:scapture/Providers/UserProvider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:video_player/video_player.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class GameScreen extends StatefulWidget {
//   const GameScreen({super.key});

//   @override
//   _GameScreenState createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
//   VideoPlayerController? _yesVideoController;
//   VideoPlayerController? _noVideoController;
//   AnimationController? _colorAnimationController;
//   Animation<double>? _colorAnimation;
//   final TextEditingController _scriptureController = TextEditingController();

//   bool _showingVideo = false;
//   bool _isYesVideo = false;
//   String _currentThought = "";
//   String? _currentScripture;
//   int _currentLevel = 0;
//   int _currentStage = 0;
//   int _totalStages = 0;
//   bool _isLoading = true;
//   Map<String, dynamic>? _currentCategory;
//   List<Map<String, dynamic>> _thoughts = [];

//   final supabase = Supabase.instance.client;
//   final String openAiApiKey = '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';

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideos();
//     _setupColorAnimation();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchUserProgress();
//     });
//   }

//   void _initializeVideos() {
//     _yesVideoController = VideoPlayerController.asset('assets/videos/yes.mp4');
//     _noVideoController = VideoPlayerController.asset('assets/videos/no.mp4');

//     _yesVideoController!.initialize().then((_) => setState(() {}));
//     _noVideoController!.initialize().then((_) => setState(() {}));
//   }

//   void _setupColorAnimation() {
//     _colorAnimationController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     );

//     _colorAnimation = Tween<double>(
//       begin: 0.0,
//       end: 0.4,
//     ).animate(CurvedAnimation(
//       parent: _colorAnimationController!,
//       curve: Curves.easeInOut,
//     ));
//   }

//   Future<void> _fetchUserProgress() async {
//     setState(() => _isLoading = true);

//     try {
//       final userProvider = Provider.of<UserProvider>(context, listen: false);
//       await userProvider.refreshUserData();

//       if (userProvider.userData == null) {
//         setState(() => _isLoading = false);
//         return;
//       }

//       // Safely parse level and stage
//       _currentLevel = int.tryParse(userProvider.userData!['current_level'].toString()) ?? 0;
//       _currentStage = int.tryParse(userProvider.userData!['current_stage'].toString()) ?? 0;

//       // Fetch categories ordered by order_index
//       final categories = await supabase
//           .from('anxiety_categories')
//           .select()
//           .order('order_index');

//       if (categories.isEmpty) {
//         print('No categories found');
//         setState(() => _isLoading = false);
//         return;
//       }

//       // Check if completed all levels
//       if (_currentLevel >= categories.length) {
//         _currentLevel = 0;
//         _currentStage = 0;
//         await _updateUserProgressInDB(_currentLevel, _currentStage, null, null);
//       }

//       _currentCategory = categories[_currentLevel];
//       print('Current category: ${_currentCategory!['name']}');

//       // Fetch thoughts for current category with proper join
//       final thoughtsResponse = await supabase
//           .from('negative_thoughts')
//           .select('''
//             id,
//             thought_text,
//             order_index,
//             scriptures!inner (
//               id,
//               verse_text
//             )
//           ''')
//           .eq('anx_id', _currentCategory!['id'])
//           .order('order_index');

//       _thoughts = thoughtsResponse;
//       _totalStages = _thoughts.length;

//       print('Total stages: $_totalStages');
//       print('Current stage: $_currentStage');

//       // Set current thought and scripture
//       if (_thoughts.isNotEmpty && _currentStage < _thoughts.length) {
//         _currentThought = _thoughts[_currentStage]['thought_text'] ?? '';
        
//         // Handle scripture data structure
//         var scriptureData = _thoughts[_currentStage]['scriptures'];
//         if (scriptureData is List && scriptureData.isNotEmpty) {
//           _currentScripture = scriptureData[0]['verse_text'];
//         } else if (scriptureData is Map) {
//           _currentScripture = scriptureData['verse_text'];
//         }

//         print('Current thought: $_currentThought');
//         print('Current scripture: $_currentScripture');
//       }
//     } catch (e) {
//       print('Error in _fetchUserProgress: $e');
//     }

//     setState(() => _isLoading = false);
//   }

//   Future<bool> _checkScriptureSimilarity(String userInput) async {
//     if (_currentScripture == null || _currentScripture!.isEmpty) {
//       print('No scripture to compare against');
//       return false;
//     }

//     if (userInput.trim().isEmpty) {
//       print('User input is empty');
//       return false;
//     }

//     try {
//       print('Comparing:');
//       print('Original: $_currentScripture');
//       print('User input: $userInput');

//       final response = await http.post(
//         Uri.parse('https://api.openai.com/v1/chat/completions'),
//         headers: {
//           'Authorization': 'Bearer $openAiApiKey',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'model': 'gpt-3.5-turbo',
//           'messages': [
//             {
//               'role': 'system',
//               'content': '''You are a text similarity checker. Compare two Bible verses or religious texts and return only a similarity score between 0 and 100. 
//               Consider semantic meaning, key words, and overall message. 
//               Focus on the spiritual meaning rather than exact word matching.
//               Respond with ONLY the number (0-100), nothing else.'''
//             },
//             {
//               'role': 'user',
//               'content': 'Original text: "$_currentScripture"\n\nUser input: "$userInput"\n\nSimilarity score:'
//             }
//           ],
//           'max_tokens': 10,
//           'temperature': 0.1,
//         }),
//       );

//       print('API Response Status: ${response.statusCode}');
//       print('API Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         String content = jsonResponse['choices'][0]['message']['content'].toString().trim();
        
//         // Extract number from response
//         RegExp regExp = RegExp(r'\d+');
//         Match? match = regExp.firstMatch(content);
        
//         if (match != null) {
//           int score = int.parse(match.group(0)!);
//           print('Similarity score: $score');
//           return score >= 70;
//         } else {
//           print('Could not extract score from: $content');
//           return false;
//         }
//       } else {
//         print('API Error: ${response.statusCode} - ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       print('Error checking similarity: $e');
//       return false;
//     }
//   }

//   Future<void> _updateUserProgressInDB(int newLevel, int newStage, int? battlesWon, int? totalBattles) async {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
    
//     try {
//       Map<String, dynamic> updateData = {
//         'current_level': newLevel,
//         'current_stage': newStage,
//       };

//       if (battlesWon != null) {
//         updateData['battles_won'] = battlesWon;
//       }
//       if (totalBattles != null) {
//         updateData['total_battles'] = totalBattles;
//       }

//       await supabase.from('users').update(updateData).eq('user_id', userProvider.userData!['user_id']);
//       await userProvider.refreshUserData();
      
//       print('Progress updated: Level $_currentLevel, Stage $_currentStage');
//     } catch (e) {
//       print('Error updating user progress: $e');
//     }
//   }

//   Future<void> _updateUserProgress(bool isCorrect) async {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     int newLevel = _currentLevel;
//     int newStage = _currentStage;
//     int battlesWon = int.tryParse(userProvider.userData!['battles_won'].toString()) ?? 0;
//     int totalBattles = int.tryParse(userProvider.userData!['total_battles'].toString()) ?? 0;

//     if (isCorrect) {
//       newStage++;
//       battlesWon++;
      
//       // Check if completed all stages in current level
//       if (newStage >= _totalStages) {
//         newLevel++;
//         newStage = 0;
//         print('Level completed! Moving to level $newLevel');
//       }
//     }
//     totalBattles++;

//     await _updateUserProgressInDB(newLevel, newStage, battlesWon, totalBattles);
    
//     // Update local variables
//     _currentLevel = newLevel;
//     _currentStage = newStage;
//   }

//   void _playVideo(bool isCorrect) async {
//     setState(() {
//       _showingVideo = true;
//       _isYesVideo = isCorrect;
//     });

//     VideoPlayerController controller = isCorrect ? _yesVideoController! : _noVideoController!;

//     await controller.seekTo(Duration.zero);
//     await controller.play();
//     _colorAnimationController!.forward();

//     // Show dialog after video
//     Future.delayed(const Duration(seconds: 3), () async {
//       await controller.pause();
//       await controller.seekTo(Duration.zero);
//       _colorAnimationController!.reset();

//       setState(() => _showingVideo = false);

//       if (isCorrect) {
//         await _updateUserProgress(true);
        
//         // Check if need to fetch new data (level changed)
//         if (_currentStage == 0) {
//           await _fetchUserProgress();
//         } else {
//           // Just update current thought and scripture
//           if (_currentStage < _thoughts.length) {
//             _currentThought = _thoughts[_currentStage]['thought_text'] ?? '';
//             var scriptureData = _thoughts[_currentStage]['scriptures'];
//             if (scriptureData is List && scriptureData.isNotEmpty) {
//               _currentScripture = scriptureData[0]['verse_text'];
//             } else if (scriptureData is Map) {
//               _currentScripture = scriptureData['verse_text'];
//             }
//           }
//         }

//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Congratulations!'),
//             content: Text(_currentStage == 0 
//               ? 'Level completed! Moving to next category.'
//               : 'Correct answer! Ready for the next challenge?'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   setState(() {});
//                 },
//                 child: Text(_currentStage == 0 ? 'Next Level' : 'Next Stage'),
//               ),
//             ],
//           ),
//         );
//       } else {
//         await _updateUserProgress(false);
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Try Again'),
//             content: const Text('Your answer was incorrect. Want to try again?'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   setState(() {});
//                 },
//                 child: const Text('Try Again'),
//               ),
//             ],
//           ),
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _yesVideoController?.dispose();
//     _noVideoController?.dispose();
//     _colorAnimationController?.dispose();
//     _scriptureController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<UserProvider>(
//       builder: (context, userProvider, child) {
//         if (userProvider.isLoading || _isLoading) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (userProvider.userData == null) {
//           return const Scaffold(
//             body: Center(child: Text('Error loading user data', style: TextStyle(color: Colors.white))),
//           );
//         }

//         return Scaffold(
//           backgroundColor: const Color(0xFF1A237E),
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () => Navigator.pop(context),
//             ),
//             title: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const CircleAvatar(
//                     radius: 12,
//                     backgroundColor: Colors.amber,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Level ${_currentLevel + 1} | ${_currentCategory?['name'] ?? 'Loading...'}',
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           body: AnimatedBuilder(
//             animation: _colorAnimation!,
//             builder: (context, child) {
//               return Container(
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/images/bgStatic.png'),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     Column(
//                       children: [
//                         // Progress Bar
//                         Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             children: [
//                               Text(
//                                 'Progress: $_currentStage/$_totalStages',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               LinearProgressIndicator(
//                                 value: _totalStages > 0 ? _currentStage / _totalStages : 0,
//                                 backgroundColor: Colors.white.withOpacity(0.3),
//                                 valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 // Negative Thought
//                                 Container(
//                                   margin: const EdgeInsets.symmetric(horizontal: 40),
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     _currentThought.isEmpty ? 'Loading thought...' : _currentThought,
//                                     style: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 40),
//                                 // Video/Battle Area
//                                 Container(
//                                   height: 300,
//                                   child: _showingVideo
//                                       ? ClipRRect(
//                                           borderRadius: BorderRadius.circular(20),
//                                           child: AspectRatio(
//                                             aspectRatio: _isYesVideo
//                                                 ? _yesVideoController!.value.aspectRatio
//                                                 : _noVideoController!.value.aspectRatio,
//                                             child: VideoPlayer(
//                                               _isYesVideo ? _yesVideoController! : _noVideoController!,
//                                             ),
//                                           ),
//                                         ): null
//                                       // : Container(
//                                       //     decoration: BoxDecoration(
//                                       //       color: const Color(0xFF0D1B3E),
//                                       //       borderRadius: BorderRadius.circular(20),
//                                       //     ),
//                                       //     child: const Center(
//                                       //       child: Text(
//                                       //         '⚔️ Battle Arena ⚔️',
//                                       //         style: TextStyle(
//                                       //           color: Colors.white,
//                                       //           fontSize: 24,
//                                       //           fontWeight: FontWeight.bold,
//                                       //         ),
//                                       //       ),
//                                       //     ),
//                                       //   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         // Bottom Section
//                         Container(
//                           padding: const EdgeInsets.all(10),
//                           child: Column(
//                             children: [
//                               // Debug info (remove in production)
//                               if (_currentScripture != null)
//                                 Container(
//                                   padding: const EdgeInsets.all(8),
//                                   margin: const EdgeInsets.only(bottom: 10),
//                                   decoration: BoxDecoration(
//                                     color: Colors.black54,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     'Expected: $_currentScripture',
//                                     style: const TextStyle(color: Colors.white, fontSize: 12),
//                                   ),
//                                 ),
//                               // Scripture Input
//                               TextField(
//                                 controller: _scriptureController,
//                                 style: const TextStyle(color: Colors.white),
//                                 decoration: InputDecoration(
//                                   hintText: 'Type the scripture here...',
//                                   hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//                                   filled: true,
//                                   fillColor: Colors.white.withOpacity(0.2),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(25),
//                                     borderSide: BorderSide.none,
//                                   ),
//                                 ),
//                                 maxLines: 3,
//                               ),
//                               const SizedBox(height: 16),
//                               // Submit Button
//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 50,
//                                 child: ElevatedButton(
//                                   onPressed: _showingVideo ? null : () async {
//                                     if (_scriptureController.text.trim().isEmpty) {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         const SnackBar(content: Text('Please enter a scripture')),
//                                       );
//                                       return;
//                                     }
                                    
//                                     final isCorrect = await _checkScriptureSimilarity(_scriptureController.text);
//                                     _playVideo(isCorrect);
//                                     _scriptureController.clear();
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.white,
//                                     foregroundColor: Colors.black,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(25),
//                                     ),
//                                   ),
//                                   child: const Text(
//                                     'Submit',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     // Color Overlay
//                     if (_showingVideo)
//                       Container(
//                         color: (_isYesVideo ? Colors.green : Colors.red).withOpacity(_colorAnimation!.value),
//                       ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:scapture/Providers/UserProvider.dart';
import 'package:scapture/UI/SubscriptionPlans.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  VideoPlayerController? _yesVideoController;
  VideoPlayerController? _noVideoController;
  AnimationController? _colorAnimationController;
  Animation<double>? _colorAnimation;
  final TextEditingController _scriptureController = TextEditingController();

  bool _showingVideo = false;
  bool _isYesVideo = false;
  String _currentThought = "";
  String? _currentScripture;
  int _currentLevel = 0;
  int _currentStage = 0;
  int _totalStages = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _currentCategory;
  List<Map<String, dynamic>> _thoughts = [];

  final supabase = Supabase.instance.client;
  final String openAiApiKey = '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';

  @override
  void initState() {
    super.initState();
    _initializeVideos();
    _setupColorAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserProgress();
    });
  }

  void _initializeVideos() {
    _yesVideoController = VideoPlayerController.asset('assets/videos/yes.mp4');
    _noVideoController = VideoPlayerController.asset('assets/videos/no.mp4');

    _yesVideoController!.initialize().then((_) => setState(() {}));
    _noVideoController!.initialize().then((_) => setState(() {}));
  }

  void _setupColorAnimation() {
    _colorAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _colorAnimation = Tween<double>(
      begin: 0.0,
      end: 0.4,
    ).animate(CurvedAnimation(
      parent: _colorAnimationController!,
      curve: Curves.easeInOut,
    ));
  }

  void _showPremiumAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Free Limit Reached'),
        content: const Text(
          'Your free limit has ended. Please purchase a premium subscription to unlock all levels and stages.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset to Level 1, Stage 0
              _updateUserProgressInDB(0, 0, null, null).then((_) {
                _fetchUserProgress();
              });
            },
            child: const Text('Play Again Level 1'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Redirect to premium purchase page
              // You can replace this with actual navigation to your app's premium purchase screen
              Get.to(()=>SubscriptionScreen());
            },
            child: const Text('Buy Premium'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchUserProgress() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUserData();

      if (userProvider.userData == null) {
        setState(() => _isLoading = false);
        return;
      }

      bool isPremium = userProvider.userData!['is_premium'] ?? false;
      _currentLevel = int.tryParse(userProvider.userData!['current_level'].toString()) ?? 0;
      _currentStage = int.tryParse(userProvider.userData!['current_stage'].toString()) ?? 0;

      // Fetch categories ordered by order_index
      final categories = await supabase
          .from('anxiety_categories')
          .select()
          .order('order_index');

      if (categories.isEmpty) {
        print('No categories found');
        setState(() => _isLoading = false);
        return;
      }

      // Non-premium user restrictions
      if (!isPremium) {
        if (_currentLevel > 0) {
          // If trying to access a level beyond 0, reset to Level 1, Stage 0 and show alert
          await _updateUserProgressInDB(0, 0, null, null);
          _currentLevel = 0;
          _currentStage = 0;
          setState(() => _isLoading = false);
          _showPremiumAlertDialog();
          return;
        }

        // Check if Level 1 is completed (all stages done)
        final thoughtsResponse = await supabase
            .from('negative_thoughts')
            .select('id')
            .eq('anx_id', categories[0]['id']);
        _totalStages = thoughtsResponse.length;

        if (_currentStage >= _totalStages && _currentLevel == 0) {
          // Level 1 completed, show alert and reset
          await _updateUserProgressInDB(0, 0, null, null);
          _currentLevel = 0;
          _currentStage = 0;
          setState(() => _isLoading = false);
          _showPremiumAlertDialog();
          return;
        }
      }

      // Existing logic for premium users or allowed Level 1 for non-premium
      if (_currentLevel >= categories.length) {
        _currentLevel = 0;
        _currentStage = 0;
        await _updateUserProgressInDB(_currentLevel, _currentStage, null, null);
      }

      _currentCategory = categories[_currentLevel];
      print('Current category: ${_currentCategory!['name']}');

      // Fetch thoughts for current category
      final thoughtsResponse = await supabase
          .from('negative_thoughts')
          .select('''
            id,
            thought_text,
            order_index,
            scriptures!inner (
              id,
              verse_text
            )
          ''')
          .eq('anx_id', _currentCategory!['id'])
          .order('order_index');

      _thoughts = thoughtsResponse;
      _totalStages = _thoughts.length;

      print('Total stages: $_totalStages');
      print('Current stage: $_currentStage');

      if (_thoughts.isNotEmpty && _currentStage < _thoughts.length) {
        _currentThought = _thoughts[_currentStage]['thought_text'] ?? '';
        var scriptureData = _thoughts[_currentStage]['scriptures'];
        if (scriptureData is List && scriptureData.isNotEmpty) {
          _currentScripture = scriptureData[0]['verse_text'];
        } else if (scriptureData is Map) {
          _currentScripture = scriptureData['verse_text'];
        }

        print('Current thought: $_currentThought');
        print('Current scripture: $_currentScripture');
      }
    } catch (e) {
      print('Error in _fetchUserProgress: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<bool> _checkScriptureSimilarity(String userInput) async {
    if (_currentScripture == null || _currentScripture!.isEmpty) {
      print('No scripture to compare against');
      return false;
    }

    if (userInput.trim().isEmpty) {
      print('User input is empty');
      return false;
    }

    try {
      print('Comparing:');
      print('Original: $_currentScripture');
      print('User input: $userInput');

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $openAiApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a text similarity checker. Compare two Bible verses or religious texts and return only a similarity score between 0 and 100. 
              Consider semantic meaning, key words, and overall message. 
              Focus on the spiritual meaning rather than exact word matching.
              Respond with ONLY the number (0-100), nothing else.'''
            },
            {
              'role': 'user',
              'content': 'Original text: "$_currentScripture"\n\nUser input: "$userInput"\n\nSimilarity score:'
            }
          ],
          'max_tokens': 10,
          'temperature': 0.1,
        }),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String content = jsonResponse['choices'][0]['message']['content'].toString().trim();
        
        RegExp regExp = RegExp(r'\d+');
        Match? match = regExp.firstMatch(content);
        
        if (match != null) {
          int score = int.parse(match.group(0)!);
          print('Similarity score: $score');
          return score >= 70;
        } else {
          print('Could not extract score from: $content');
          return false;
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error checking similarity: $e');
      return false;
    }
  }

  Future<void> _updateUserProgressInDB(int newLevel, int newStage, int? battlesWon, int? totalBattles) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      Map<String, dynamic> updateData = {
        'current_level': newLevel,
        'current_stage': newStage,
      };

      if (battlesWon != null) {
        updateData['battles_won'] = battlesWon;
      }
      if (totalBattles != null) {
        updateData['total_battles'] = totalBattles;
      }

      await supabase.from('users').update(updateData).eq('user_id', userProvider.userData!['user_id']);
      await userProvider.refreshUserData();
      
      print('Progress updated: Level $_currentLevel, Stage $_currentStage');
    } catch (e) {
      print('Error updating user progress: $e');
    }
  }

  Future<void> _updateUserProgress(bool isCorrect) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool isPremium = userProvider.userData!['is_premium'] ?? false;
    int newLevel = _currentLevel;
    int newStage = _currentStage;
    int battlesWon = int.tryParse(userProvider.userData!['battles_won'].toString()) ?? 0;
    int totalBattles = int.tryParse(userProvider.userData!['total_battles'].toString()) ?? 0;

    if (isCorrect) {
      newStage++;
      battlesWon++;
      
      if (newStage >= _totalStages) {
        newLevel++;
        newStage = 0;
        print('Level completed! Moving to level $newLevel');
      }
    }
    totalBattles++;

    await _updateUserProgressInDB(newLevel, newStage, battlesWon, totalBattles);
    
    _currentLevel = newLevel;
    _currentStage = newStage;

    // For non-premium users, check if Level 1 is completed
    if (!isPremium && _currentLevel == 0 && _currentStage >= _totalStages) {
      _showPremiumAlertDialog();
    }
  }

  void _playVideo(bool isCorrect) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool isPremium = userProvider.userData!['is_premium'] ?? false;

    // Prevent non-premium users from proceeding to higher levels
    if (!isPremium && _currentLevel > 0) {
      _showPremiumAlertDialog();
      return;
    }

    setState(() {
      _showingVideo = true;
      _isYesVideo = isCorrect;
    });

    VideoPlayerController controller = isCorrect ? _yesVideoController! : _noVideoController!;

    await controller.seekTo(Duration.zero);
    await controller.play();
    _colorAnimationController!.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      await controller.pause();
      await controller.seekTo(Duration.zero);
      _colorAnimationController!.reset();

      setState(() => _showingVideo = false);

      if (isCorrect) {
        await _updateUserProgress(true);
        
        if (_currentStage == 0) {
          await _fetchUserProgress();
        } else {
          if (_currentStage < _thoughts.length) {
            _currentThought = _thoughts[_currentStage]['thought_text'] ?? '';
            var scriptureData = _thoughts[_currentStage]['scriptures'];
            if (scriptureData is List && scriptureData.isNotEmpty) {
              _currentScripture = scriptureData[0]['verse_text'];
            } else if (scriptureData is Map) {
              _currentScripture = scriptureData['verse_text'];
            }
          }
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Congratulations!'),
            content: Text(_currentStage == 0 
              ? 'Level completed! Moving to next category.'
              : 'Correct answer! Ready for the next challenge?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Check premium status before proceeding
                  if (!isPremium && _currentLevel > 0) {
                    _showPremiumAlertDialog();
                  } else {
                    setState(() {});
                  }
                },
                child: Text(_currentStage == 0 ? 'Next Level' : 'Next Stage'),
              ),
            ],
          ),
        );
      } else {
        await _updateUserProgress(false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Try Again'),
            content: const Text('Your answer was incorrect. Want to try again?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        );
      }
    });
  }
  

  @override
  void dispose() {
    _yesVideoController?.dispose();
    _noVideoController?.dispose();
    _colorAnimationController?.dispose();
    _scriptureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading || _isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userProvider.userData == null) {
          return const Scaffold(
            body: Center(child: Text('Error loading user data', style: TextStyle(color: Colors.white))),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF1A237E),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Level ${_currentLevel + 1} | ${_currentCategory?['name'] ?? 'Loading...'}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: AnimatedBuilder(
            animation: _colorAnimation!,
            builder: (context, child) {
              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bgStatic.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Progress: $_currentStage/$_totalStages',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _totalStages > 0 ? _currentStage / _totalStages : 0,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 40),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _currentThought.isEmpty ? 'Loading thought...' : _currentThought,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Container(
                                  height: 300,
                                  child: _showingVideo
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: AspectRatio(
                                            aspectRatio: _isYesVideo
                                                ? _yesVideoController!.value.aspectRatio
                                                : _noVideoController!.value.aspectRatio,
                                            child: VideoPlayer(
                                              _isYesVideo ? _yesVideoController! : _noVideoController!,
                                            ),
                                          ),
                                        ): null
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              if (_currentScripture != null)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Expected: $_currentScripture',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              TextField(
                                controller: _scriptureController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Type the scripture here...',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _showingVideo ? null : () async {
                                    if (_scriptureController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter a scripture')),
                                      );
                                      return;
                                    }
                                    
                                    final isCorrect = await _checkScriptureSimilarity(_scriptureController.text);
                                    _playVideo(isCorrect);
                                    _scriptureController.clear();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_showingVideo)
                      Container(
                        color: (_isYesVideo ? Colors.green : Colors.red).withOpacity(_colorAnimation!.value),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
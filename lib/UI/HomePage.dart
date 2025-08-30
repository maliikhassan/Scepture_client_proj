import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:scapture/Providers/CategoryProvider.dart';
import 'package:scapture/Providers/UserProvider.dart';
import 'package:scapture/UI/CategoryScreen.dart';
import 'package:scapture/UI/Negthought2.dart';
import 'package:scapture/UI/ProfileScreen.dart';
import 'package:scapture/UI/RemindersScreen.dart';
import 'package:scapture/UI/aboutScreen.dart';
import 'package:scapture/UI/gameScreen.dart';
import 'package:scapture/UI/jotterScreen.dart';
import 'package:scapture/UI/scriptureTrackingScreen.dart';
import 'package:scapture/UI/searchScreen.dart';
import 'package:scapture/UI/warriorMindScreen.dart';

import '../Providers/NegthoughtsProvider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    SearchScreen(),
    ScriptureTrackerScreen(),
    Profilescreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final userData = userProvider.userData;
        if (userData == null) {
          return const Center(
            child: Text(
              'Failed to load user data',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Column(
          children: [
            // Top black section with user info
            Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.wb_sunny_outlined,
                                color: Color(0xFFEFBF04),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getGreeting(),
                                style: const TextStyle(
                                  color: Color(0xFFEFBF04),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            userData['full_name'] ?? 'Unknown User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF8B5CF6),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  // User name
                  const SizedBox(height: 10),

                  // Featured section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.8),width: 3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Take part in challenges with friends\nor other players',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.black,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Find Solution',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
            ),

            // List items in a scrollable ListView with white background
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  color: Colors.white,
                ),
                child: ListView(
                  children: [
                    _buildMenuItem(
                      icon: "assets/icons/battle.png",
                      iconColor: Colors.black,
                      title: 'Start a Battle',
                      subtitle: 'Game | 100+ Levels',
                      onTap: () => Get.to(ScepterHomeScreen()),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: "assets/icons/category.png",
                      iconColor: Colors.black,
                      title: 'Explore Anxiety Categories',
                      subtitle: 'Anxiety Solutions | 100+ relevant',
                      onTap: () => Get.to(AnxietyCategoryScreen()),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: "assets/icons/tracker.png",
                      iconColor: Colors.black,
                      title: 'Scripture Tracker',
                      subtitle: 'History | Track your interactions',
                      onTap: () {
                        Get.to(()=> ScriptureTrackerScreen());
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: "assets/icons/remainder.png",
                      iconColor: Colors.black,
                      title: 'Prepare for Battle',
                      subtitle: 'Get Notified | Set Reminders',
                      onTap: () {
                        Get.to(()=>MyBattleRemindersScreen());
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: "assets/icons/warrior.png",
                      iconColor: Colors.black,
                      title: "A warrior's mind devotional",
                      subtitle: 'Improve your Mind Health',
                      onTap: () {
                        Get.to(()=> WarriorsMindScreen());
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: "assets/icons/journal.png",
                      iconColor: Colors.black,
                      title: 'Overcomers Journal',
                      subtitle: 'Find your relevance from Journals',
                      onTap: () {
                        Get.to(()=> JotterListScreen());
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: "assets/icons/about.png",
                      iconColor: Colors.black,
                      title: 'About Anxiety App',
                      subtitle: 'Breif Introduction of the app',
                      onTap: () {
                        Get.to(()=>AnxietyContentScreen());
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black87, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFFEFBF04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black, size: 30),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'GOOD MORNING';
    } else if (hour >= 12 && hour < 17) {
      return 'GOOD AFTERNOON';
    } else if (hour >= 17 && hour < 22) {
      return 'GOOD EVENING';
    } else {
      return 'GOOD NIGHT';
    }
  }
}

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Search'),
//         backgroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: Consumer2<NegThoughtsProvider, CategoryProvider>(
//         builder: (context, negThoughtsProvider, categoryProvider, child) {
//           if (negThoughtsProvider.isLoading || categoryProvider.isLoading) {
//             return const Center(
//               child: CircularProgressIndicator(color: Colors.white),
//             );
//           }

//           if (negThoughtsProvider.errorMessage != null ||
//               categoryProvider.errorMessage != null) {
//             return Center(
//               child: Text(
//                 negThoughtsProvider.errorMessage ??
//                     categoryProvider.errorMessage ??
//                     'Unknown error',
//                 style: const TextStyle(color: Colors.redAccent),
//               ),
//             );
//           }

//           // Merge categories and negThoughts into one searchable list
//           final mergedList = [
//             ...categoryProvider.categories.map(
//               (cat) => cat['name'] as String? ?? 'Unnamed Category',
//             ),
//             ...negThoughtsProvider.negThoughts.map(
//               (neg) => neg['thought_text'] as String? ?? 'Unnamed Thought',
//             ),
//           ];

//           final query = _searchController.text.toLowerCase().trim();
//           final filteredList =
//               query.isEmpty
//                   ? mergedList
//                   : mergedList.where((item) {
//                     return item.toLowerCase().contains(query);
//                   }).toList();

//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: TextField(
//                   controller: _searchController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: Colors.grey[900],
//                     hintText: 'Search...',
//                     hintStyle: const TextStyle(color: Colors.white54),
//                     prefixIcon: const Icon(Icons.search, color: Colors.white),
//                     suffixIcon:
//                         _searchController.text.isNotEmpty
//                             ? IconButton(
//                               icon: const Icon(
//                                 Icons.clear,
//                                 color: Colors.white70,
//                               ),
//                               onPressed: () {
//                                 _searchController.clear();
//                                 FocusScope.of(context).unfocus();
//                               },
//                             )
//                             : null,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child:
//                     filteredList.isEmpty
//                         ? const Center(
//                           child: Text(
//                             'No results found',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 16,
//                             ),
//                           ),
//                         )
//                         : ListView.separated(
//                           itemCount: filteredList.length,
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           separatorBuilder:
//                               (_, __) => const SizedBox(height: 8),
//                           itemBuilder: (context, index) {
//                             final item = filteredList[index];
//                             return Card(
//                               color: Colors.grey[850],
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: ListTile(
//                                 title: Text(
//                                   item,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 10,
//                                   horizontal: 16,
//                                 ),
//                                 onTap: () {
//                                   // Check if item is a category
//                                   final isCategory = categoryProvider.categories
//                                       .any((cat) => cat['name'] == item);
//                                   if (isCategory) {
//                                     Get.to(() => AnxietyCategoryScreen());
//                                   } else {
//                                     Get.to(NegThought2Screen(negThought: item));
//                                   }
//                                 },
//                               ),
//                             );
//                           },
//                         ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scapture/UI/RemindersScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScriptureTrackerScreen extends StatefulWidget {
  const ScriptureTrackerScreen({Key? key}) : super(key: key);

  @override
  State<ScriptureTrackerScreen> createState() => _ScriptureTrackerScreenState();
}

class _ScriptureTrackerScreenState extends State<ScriptureTrackerScreen> {
  String selectedPeriod = 'Monthly';
  Map<String, dynamic>? userData;
  bool isLoading = true;
  
  // Data variables that will be populated from Supabase
  int totalGamesThisMonth = 0;
  int totalGamesPlayed = 0;
  int totalGamesLimit = 100; // Default limit, can be made configurable
  int gamesThisWeek = 0;
  int gamesWon = 0;
  int points = 0;
  int worldRank = 0;
  int localRank = 0;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Fetch user profile data
        final userResponse = await Supabase.instance.client
            .from('users')
            .select()
            .eq('user_id', user.id)
            .single();
        
        setState(() {
          userData = userResponse;
          // Map database fields to display values
          totalGamesPlayed = userResponse['total_battles'] ?? 0;
          gamesWon = userResponse['battles_won'] ?? 0;
          
          // Calculate derived values
          _calculateDerivedStats();
          
          isLoading = false;
        });
        
        // Fetch rankings after we have the user data
        await _fetchRankings();
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _calculateDerivedStats() {
    // Calculate points based on battles won (you can adjust this formula)
    points = gamesWon * 10; // 10 points per win
    
    // Since we don't have session-based data, we'll estimate based on available data
    // For this month's games, we'll use a percentage of total games
    // This is a simplified approach - you might want to track this differently
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    
    // Estimate games this month based on average daily play
    if (totalGamesPlayed > 0) {
      // Assuming created_at represents when user started playing
      final accountAge = userData?['created_at'] != null 
          ? DateTime.now().difference(DateTime.parse(userData!['created_at'])).inDays
          : 30; // Default to 30 days if no date
      
      final avgGamesPerDay = accountAge > 0 ? totalGamesPlayed / accountAge : 0;
      totalGamesThisMonth = (avgGamesPerDay * daysPassed).round();
      gamesThisWeek = (avgGamesPerDay * 7).round();
      
      // Make sure we don't exceed total games
      totalGamesThisMonth = totalGamesThisMonth > totalGamesPlayed ? totalGamesPlayed : totalGamesThisMonth;
      gamesThisWeek = gamesThisWeek > totalGamesPlayed ? totalGamesPlayed : gamesThisWeek;
    }
  }

  Future<void> _fetchRankings() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Fetch world rank based on battles won
        final worldRankResponse = await Supabase.instance.client
            .from('users')
            .select('battles_won')
            .gt('battles_won', gamesWon)
            .order('battles_won', ascending: false);
        
        worldRank = worldRankResponse.length + 1;
        
        // For local rank, we'll use the same logic since we don't have location data
        // You can modify this if you add location tracking
        localRank = worldRank;
        
        setState(() {
          // Update UI after fetching rankings
        });
      }
    } catch (e) {
      print('Error fetching rankings: $e');
    }
  }

  // Add refresh functionality
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scripture Tracker',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Profile Section
                    _buildProfileSection(),
                    
                    const SizedBox(height: 30),
                    
                    // Stats Cards
                    _buildStatsCards(),
                    
                    const SizedBox(height: 30),
                    
                    // Monthly Progress Card
                    _buildMonthlyProgressCard(),
                    
                    const SizedBox(height: 20),
                    
                    // Bottom Stats
                    _buildBottomStats(),
                    
                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        // Profile Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.purple.shade300, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child:           false // No avatar URL field in current schema
              ? ClipOval(
                  child: Image.network(
                    '', // No avatar URL available
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      );
                    },
                  ),
                )
              : const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
        ),
        
        const SizedBox(height: 15),
        
        // Username with level info
        Column(
          children: [
            Text(
              userData?['full_name'] ?? 'User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Level ${userData?['current_level'] ?? 0} • Stage ${userData?['current_stage'] ?? 0}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('BATTLES WON', _formatNumber(gamesWon), Icons.star_border),
          _buildStatItem('STREAK', '${userData?['streak_count'] ?? 0}', Icons.local_fire_department),
          _buildStatItem('WORLD RANK', '#${_formatNumber(worldRank)}', Icons.public),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyProgressCard() {
    double progressValue = totalGamesLimit > 0 ? (totalGamesThisMonth / totalGamesLimit).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(), // Empty space for alignment
              GestureDetector(
                onTap: () {
                  // Add dropdown functionality here if needed
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedPeriod,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress text
          Text(
            'You have played a total $totalGamesThisMonth\ntimes this month!',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Progress Circle
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade800),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalGamesThisMonth',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/$totalGamesLimit',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Games played',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStats() {
    return InkWell(
      onTap: (){
        //Get.to(MyBattleRemindersScreen());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$gamesThisWeek',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Games this week',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade900,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$gamesWon',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Games won',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
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

  // Helper method to format numbers
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
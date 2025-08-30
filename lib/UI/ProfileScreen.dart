import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:scapture/Database/Database.dart';
import 'package:scapture/Providers/UserProvider.dart';
import 'package:intl/intl.dart';
import 'package:scapture/UI/SubscriptionPlans.dart';
import 'package:scapture/UI/contactUs.dart';

class Profilescreen extends StatefulWidget {
  @override
  _ProfilescreenState createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  Database _database = Database();
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    // Refresh user data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).refreshUserData();
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  String _getSubscriptionStatus(Map<String, dynamic> userData) {
    final isPremium = userData['is_premium'] ?? false;
    final subscriptionType = userData['subscription_type'] ?? 'free';
    final expiresAt = userData['subscription_expires_at'];
    
    if (isPremium && expiresAt != null) {
      final expiryDate = DateTime.parse(expiresAt);
      final now = DateTime.now();
      
      if (expiryDate.isAfter(now)) {
        return 'Premium ${subscriptionType.toString().toUpperCase()}';
      } else {
        return 'Expired Premium';
      }
    }
    
    return 'Basic Plan';
  }

  bool _isPremiumActive(Map<String, dynamic> userData) {
    final isPremium = userData['is_premium'] ?? false;
    final expiresAt = userData['subscription_expires_at'];
    
    if (isPremium && expiresAt != null) {
      final expiryDate = DateTime.parse(expiresAt);
      return expiryDate.isAfter(DateTime.now());
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: const SizedBox(), // Remove back button
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.userData == null) {
            return const Center(
              child: Text(
                'Error loading profile data',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          final userData = userProvider.userData!;
          final isPremium = _isPremiumActive(userData);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Profile Picture
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.purple,
                            child: Text(
                              userData['full_name'] != null && userData['full_name'].isNotEmpty
                                  ? userData['full_name'][0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (isPremium)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Name and Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['full_name'] ?? 'Unknown User',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userData['email'] ?? 'No email',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Menu Items
                // _buildMenuItem(
                //   'Location', 
                //   'alex, egypt', 
                //   Icons.location_on_outlined,
                //   () {},
                // ),
                _buildToggleMenuItem(
                  'Notifications', 
                  Icons.notifications_outlined,
                  _notificationsEnabled,
                  (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                // _buildMenuItem(
                //   'Language', 
                //   'EN', 
                //   Icons.language_outlined,
                //   () {},
                // ),
                // _buildToggleMenuItem(
                //   'Dark mood', 
                //   Icons.dark_mode_outlined,
                //   _darkModeEnabled,
                //   (value) {
                //     setState(() {
                //       _darkModeEnabled = value;
                //     });
                //   },
                // ),
                _buildMenuItem(
                  'Help', 
                  '', 
                  Icons.help_outline,
                  () {},
                ),
                _buildMenuItem(
                  'Log out', 
                  '', 
                  Icons.logout,
                  () async {
                    setState(() => _isLoading = true);
                    await _database.logout();
                    setState(() => _isLoading = false);
                  },
                ),
                
                // Subscription Plan
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.card_membership_outlined,
                        color: Colors.black,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _getSubscriptionStatus(userData),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (!isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Upgrade',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          if (!isPremium) {
                            Get.to(() => SubscriptionScreen());
                          }
                        },
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height:15),
                _buildMenuItem(
                  'Contact Us', 
                  '', 
                  Icons.contact_page,
                  () {
                    Get.to(()=> ContactUsScreen());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.black,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                if (subtitle.isNotEmpty) const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleMenuItem(String title, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.black,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
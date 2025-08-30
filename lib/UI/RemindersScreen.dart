import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scapture/UI/SetReminder.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class MyBattleRemindersScreen extends StatefulWidget {
  const MyBattleRemindersScreen({super.key});

  @override
  State<MyBattleRemindersScreen> createState() =>
      _MyBattleRemindersScreenState();
}

class _MyBattleRemindersScreenState extends State<MyBattleRemindersScreen> {
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }
  

  Future<void> _fetchReminders() async {
    setState(() => _isLoading = true);
    try {
      final database = await openDatabase(
        join(await getDatabasesPath(), 'scapture_database.db'),
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE MyReminders (
              re_id INTEGER PRIMARY KEY AUTOINCREMENT,
              Category TEXT NOT NULL,
              Neg_Thought TEXT NOT NULL,
              re_time TEXT NOT NULL,
              is_active INTEGER NOT NULL DEFAULT 1
            )
          ''');
        },
      );
      // If the table was created before, add the column if not exists (migration)
      await database
          .execute('''
        ALTER TABLE MyReminders ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1
      ''')
          .catchError((_) {}); // Ignore error if column exists

      final List<Map<String, dynamic>> reminders = await database.query(
        'MyReminders',
      );
      setState(() {
        _reminders = reminders;
        _errorMessage = null;
        _isLoading = false;
      });
      await database.close();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load reminders: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addReminder(
    String category,
    String negThought,
    String reTime,
  ) async {
    setState(() => _isLoading = true);
    try {
      final database = await openDatabase(
        join(await getDatabasesPath(), 'scapture_database.db'),
        version: 1,
      );
      await database.insert('MyReminders', {
        'Category': category,
        'Neg_Thought': negThought,
        're_time': reTime,
        'is_active': 1,
      });
      await _fetchReminders();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add reminder: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReminder(int reId) async {
    setState(() => _isLoading = true);
    try {
      final database = await openDatabase(
        join(await getDatabasesPath(), 'scapture_database.db'),
        version: 1,
      );
      await database.delete(
        'MyReminders',
        where: 're_id = ?',
        whereArgs: [reId],
      );
      // Do not call _cancelNotification(reId) to keep the notification active
      await _cancelNotification(reId);
      await _fetchReminders();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete reminder: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateReminder(
    int reId,
    String category,
    String negThought,
    String reTime,
  ) async {
    setState(() => _isLoading = true);
    try {
      final database = await openDatabase(
        join(await getDatabasesPath(), 'scapture_database.db'),
        version: 1,
      );
      await database.update(
        'MyReminders',
        {'Category': category, 'Neg_Thought': negThought, 're_time': reTime},
        where: 're_id = ?',
        whereArgs: [reId],
      );
      await _fetchReminders();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update reminder: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleReminder(int reId, bool isActive) async {
    setState(() => _isLoading = true);
    try {
      final database = await openDatabase(
        join(await getDatabasesPath(), 'scapture_database.db'),
        version: 1,
      );
      await database.update(
        'MyReminders',
        {'is_active': isActive ? 1 : 0},
        where: 're_id = ?',
        whereArgs: [reId],
      );
      if (!isActive) {
        await _cancelNotification(reId);
      } else {
        // Optionally, reschedule notification here if needed
      }
      await _fetchReminders();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update reminder: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMMM dd, yyyy • h:mm a').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'My Battle Reminders',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Stay prepared your remainders are listed below',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Main Content Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFEFBF04),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Reminders List
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: Colors.black),
                            )
                          : _errorMessage != null
                              ? Center(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : _reminders.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No reminders here',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: _reminders.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                                      itemBuilder: (context, index) {
                                        final reminder = _reminders[index];
                                        final scheduledTime = DateTime.parse(reminder['re_time']);
                                        final isActive = (reminder['is_active'] ?? 1) == 1;
                                        
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            children: [
                                              // Header with date and toggle
                                              Container(
                                                padding: const EdgeInsets.all(16),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      _formatDateTime(reminder['re_time']),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: isActive ? Colors.white : Colors.grey[600],
                                                      ),
                                                      child: isActive 
                                                          ? const Icon(Icons.check, color: Colors.black, size: 16)
                                                          : null,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              // Scripture quote section
                                              Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF4ECDC4),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '"For God has not given us a spirit of fear, but of power and of love and of a sound mind."',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      '2 Timothy 1:7',
                                                      style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              // Negative thought section
                                              Container(
                                                margin: const EdgeInsets.all(16),
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFEFBF04),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  reminder['Neg_Thought'],
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              
                                              // Action buttons
                                              Container(
                                                padding: const EdgeInsets.all(16),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        _toggleReminder(reminder['re_id'] as int, !isActive);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[800],
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: const Icon(
                                                          Icons.notifications_outlined,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Get.to(() => SetReminderScreen(reminder: reminder));
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[800],
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: const Icon(
                                                          Icons.edit_outlined,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => _deleteReminder(reminder['re_id'] as int),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[800],
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: const Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                    ),
                    
                    // Add Reminder Button
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Get.to(() => SetReminderScreen());
                        },
                        child: const Text(
                          'Add Reminder',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
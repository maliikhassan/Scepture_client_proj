import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scapture/Providers/UserGETXProvider.dart';
import 'package:scapture/UI/gameScreen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SetReminderScreen extends StatefulWidget {
  final Map<String, dynamic>? reminder;

  const SetReminderScreen({super.key, this.reminder});

  @override
  State<SetReminderScreen> createState() => _SetReminderScreenState();
}

class _SetReminderScreenState extends State<SetReminderScreen> {
  DateTime? _scheduledDateTime;
  String? _category;
  String? _negThought;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;
  bool _notificationEnabled = true;

  final AwesomeNotifications _awesomeNotifications = AwesomeNotifications();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchUserProgress();
    if (widget.reminder != null) {
      _category = widget.reminder!['Category'];
      _negThought = widget.reminder!['Neg_Thought'];
      _scheduledDateTime = DateTime.parse(widget.reminder!['re_time']);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _awesomeNotifications.initialize(null, [
        NotificationChannel(
          channelKey: 'reminder_channel',
          channelName: 'Reminder Notifications',
          channelDescription: 'Notification channel for reminders',
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        ),
      ], channelGroups: []);
      _awesomeNotifications.setListeners(
        onActionReceivedMethod: _onNotificationActionReceived,
      );
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _errorMessage = 'Failed to initialize notifications: $e';
        });
      }
    }
  }

  Future<void> _fetchUserProgress() async {
    if (_isDisposed) return;
    setState(() => _isLoading = true);
    try {
      final userController = Get.put(UserController());
      await userController.refreshUserData();

      final userData = userController.userData.value;
      if (userData == null) {
        if (!_isDisposed) setState(() => _isLoading = false);
        return;
      }

      final currentLevel =
          int.tryParse(userData['current_level'].toString()) ?? 0;
      final currentStage =
          int.tryParse(userData['current_stage'].toString()) ?? 0;
      final supabase = Supabase.instance.client;

      final categories = await supabase
          .from('anxiety_categories')
          .select()
          .order('order_index');

      if (categories.isEmpty) {
        if (!_isDisposed) setState(() => _isLoading = false);
        return;
      }

      _category = categories[currentLevel]['name'];

      final thoughtsResponse = await supabase
          .from('negative_thoughts')
          .select('thought_text')
          .eq('anx_id', categories[currentLevel]['id'])
          .order('order_index');

      if (currentStage < thoughtsResponse.length) {
        _negThought = thoughtsResponse[currentStage]['thought_text'];
      }

      if (!_isDisposed) setState(() => _isLoading = false);
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _errorMessage = 'Error fetching progress: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _scheduledDateTime ?? DateTime.now().add(const Duration(minutes: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (_scheduledDateTime != null) {
          _scheduledDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _scheduledDateTime!.hour,
            _scheduledDateTime!.minute,
          );
        } else {
          _scheduledDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            DateTime.now().hour + 1,
            DateTime.now().minute,
          );
        }
      });
    }
  }

  void _pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _scheduledDateTime ?? DateTime.now().add(const Duration(minutes: 1)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        if (_scheduledDateTime != null) {
          _scheduledDateTime = DateTime(
            _scheduledDateTime!.year,
            _scheduledDateTime!.month,
            _scheduledDateTime!.day,
            time.hour,
            time.minute,
          );
        } else {
          final now = DateTime.now();
          _scheduledDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          );
        }
      });
    }
  }

  Future<void> _setReminder() async {
    if (_scheduledDateTime == null ||
        _category == null ||
        _negThought == null) {
      if (!_isDisposed)
        setState(() => _errorMessage = 'Please select a date and time');
      return;
    }

    if (!_isDisposed) setState(() => _isLoading = true);
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
        onUpgrade: (db, oldVersion, newVersion) async {
          // Add migration logic if needed
        },
      );
      await database.insert('MyReminders', {
        'Category': _category!,
        'Neg_Thought': _negThought!,
        're_time': _scheduledDateTime!.toIso8601String(),
        'is_active': 1,
      });
      if (_notificationEnabled) {
        await _scheduleNotification(
          await database.query('MyReminders', orderBy: 're_id DESC', limit: 1),
        );
      }
      await database.close();
      if (!_isDisposed) {
        setState(() {
          _errorMessage = null;
          _scheduledDateTime = null;
          _isLoading = false;
        });
        Get.back();
        Get.back();
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _errorMessage = 'Failed to set reminder: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateReminder(int reId) async {
    if (_scheduledDateTime == null ||
        _category == null ||
        _negThought == null) {
      if (!_isDisposed)
        setState(() => _errorMessage = 'Please select a date and time');
      return;
    }

    if (!_isDisposed) setState(() => _isLoading = true);
    try {
      final database = await openDatabase(
        join(await getDatabasesPath(), 'scapture_database.db'),
        version: 1,
        onUpgrade: (db, oldVersion, newVersion) async {
          // Add migration logic if needed
        },
      );
      await _cancelPreviousNotification(reId);
      await database.update(
        'MyReminders',
        {
          'Category': _category!,
          'Neg_Thought': _negThought!,
          're_time': _scheduledDateTime!.toIso8601String(),
        },
        where: 're_id = ?',
        whereArgs: [reId],
      );
      if (_notificationEnabled) {
        await _scheduleNotification([
          {'re_id': reId, 're_time': _scheduledDateTime!.toIso8601String()},
        ]);
      }
      await database.close();
      if (!_isDisposed) {
        setState(() {
          _errorMessage = null;
          _scheduledDateTime = null;
          _isLoading = false;
        });
        Get.back();
        Get.back();
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _errorMessage = 'Failed to update reminder: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _scheduleNotification(
    List<Map<String, dynamic>> reminderData,
  ) async {
    try {
      final reId = reminderData[0]['re_id'].toString();
      final scheduledTime = DateTime.parse(reminderData[0]['re_time']);
      await _awesomeNotifications.createNotification(
        content: NotificationContent(
          id: int.parse(reId),
          channelKey: 'reminder_channel',
          title: '⏰ Reminder',
          body: 'Time for your $_category reminder: $_negThought',
          payload: {'re_id': reId},
          notificationLayout: NotificationLayout.Default,
          actionType: ActionType.Default,
        ),
        schedule: NotificationCalendar(
          year: scheduledTime.year,
          month: scheduledTime.month,
          day: scheduledTime.day,
          hour: scheduledTime.hour,
          minute: scheduledTime.minute,
          second: 0,
          millisecond: 0,
          repeats: false,
          allowWhileIdle: true,
        ),
      );
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _errorMessage = 'Failed to schedule notification: $e';
        });
      }
    }
  }

  Future<void> _cancelPreviousNotification(int reId) async {
    await _awesomeNotifications.cancel(reId);
  }

  Future<void> _onNotificationActionReceived(ReceivedAction action) async {
    final reId = action.payload?['re_id'];
    if (reId != null) {
      try {
        final database = await openDatabase(
          join(await getDatabasesPath(), 'scapture_database.db'),
          version: 1,
        );
        await database.delete(
          'MyReminders',
          where: 're_id = ?',
          whereArgs: [int.parse(reId)],
        );
        await database.close();

        Get.off(() => ScepterHomeScreen());
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to remove reminder: $e';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFA500),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Prepare for Battle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scripture Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF4ECDC4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Scripture',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '"For God has not given us a spirit of fear, but of power and of love and of a sound mind."',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '2 Timothy 1:7',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // Negative Thoughts Section
                        Text(
                          'Negative Thoughts',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_category != null && _negThought != null) ...[
                          Text(
                            '• I feel overwhelmed and anxious about the upcoming presentation.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Feeling inadequate about my abilities.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        
                        // Date and Time Section
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Date',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            _scheduledDateTime != null
                                                ? DateFormat('MMM dd').format(_scheduledDateTime!)
                                                : 'Select Date',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.white70,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickTime(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Time',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            _scheduledDateTime != null
                                                ? DateFormat('HH:mm').format(_scheduledDateTime!)
                                                : 'Select Time',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.white70,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // Notification Toggle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.notifications,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Notification',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _notificationEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _notificationEnabled = value;
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Add Reminder Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (widget.reminder == null) {
                            _setReminder();
                          } else {
                            _updateReminder(widget.reminder!['re_id'] as int);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(
                          'Add Reminder',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
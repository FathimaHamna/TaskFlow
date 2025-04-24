import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _projectNameController = TextEditingController();

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  Future<void> _addProject() async {
    if (_projectNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project name cannot be empty')),
      );
      return;
    }

    try {
      await _firestore.collection('projects').add({
        'name': _projectNameController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _projectNameController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Project added successfully'),
            backgroundColor: Colors.blue.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding project: $e'),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteProject(String projectId) async {
    try {
      // Begin a batch operation to delete project and all its tasks
      WriteBatch batch = _firestore.batch();
      
      // Delete the project document
      DocumentReference projectRef = _firestore.collection('projects').doc(projectId);
      batch.delete(projectRef);
      
      // Get all tasks for this project
      QuerySnapshot tasksSnapshot = await _firestore
          .collection('projectTasks')
          .where('projectId', isEqualTo: projectId)
          .get();
      
      // Add all task deletions to the batch
      for (var doc in tasksSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Commit the batch
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Project deleted successfully'),
            backgroundColor: Colors.blue.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting project: $e'),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _renameProject(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nameController = TextEditingController(text: data['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF142238),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Rename Project',
          style: TextStyle(color: Colors.blue.shade300),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Project Name',
            labelStyle: TextStyle(color: Colors.blue.shade200),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
            ),
            filled: true,
            fillColor: const Color(0x0DFFFFFF), // 5% white
            prefixIcon: Icon(Icons.folder, color: Colors.blue.shade300),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade700),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.blue.shade300)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await _firestore.collection('projects').doc(doc.id).update({
                  'name': nameController.text.trim(),
                  'updatedAt': Timestamp.now(),
                });
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Project renamed successfully'),
                      backgroundColor: Colors.blue.shade900,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project name cannot be empty')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddProjectDialog() async {
    _projectNameController.clear();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF142238),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Create New Project',
          style: TextStyle(color: Colors.blue.shade300),
        ),
        content: TextField(
          controller: _projectNameController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Project Name',
            labelStyle: TextStyle(color: Colors.blue.shade200),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
            ),
            filled: true,
            fillColor: const Color(0x0DFFFFFF), // 5% white
            prefixIcon: Icon(Icons.folder, color: Colors.blue.shade300),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade700),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.blue.shade300)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog immediately
              _addProject();            // Then run async task
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF081221), // Very dark blue
              Color(0xFF0A1829), // Dark blue
              Color(0xFF142238), // Slightly lighter dark blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Text(
                  'Organize your projects...',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade100,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              // Projects List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('projects')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.folder_open,
                              size: 80,
                              color: Color(0x4DFFFFFF), // 30% white
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No projects found',
                              style: TextStyle(
                                color: Color(0x80FFFFFF), // 50% white
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showAddProjectDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Create your first project'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        var data = doc.data() as Map<String, dynamic>;
                        
                        return GestureDetector(
                          onTap: () {
                            // Navigate to project tasks page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectTasksPage(
                                  projectId: doc.id,
                                  projectName: data['name'] ?? 'Unnamed Project',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0x1AFFFFFF), // 10% white
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0x33FFFFFF), // 20% white
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Folder Icon
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0x4D0D47A1), // 30% of blue.shade900
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.folder,
                                    size: 40,
                                    color: Colors.blue.shade300,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Project Name
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    data['name'] ?? 'Unnamed Project',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Actions Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Edit button
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue.shade300,
                                        size: 20,
                                      ),
                                      onPressed: () => _renameProject(doc),
                                    ),
                                    // Delete button
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red.shade300,
                                        size: 20,
                                      ),
                                      onPressed: () => _showDeleteConfirmation(doc.id, data['name']),
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  
  void _showDeleteConfirmation(String projectId, String projectName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF142238),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Project',
          style: TextStyle(color: Colors.red.shade300),
        ),
        content: Text(
          'Are you sure you want to delete "$projectName"? This will also delete all tasks in this project.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.blue.shade300)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteProject(projectId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Project Tasks Page - Shows tasks for a specific project
class ProjectTasksPage extends StatefulWidget {
  final String projectId;
  final String projectName;
  
  const ProjectTasksPage({
    super.key, 
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ProjectTasksPage> createState() => _ProjectTasksPageState();
}

class _ProjectTasksPageState extends State<ProjectTasksPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<TimeOfDay> _reminders = [];
  Timer? _reminderTimer;
  final List<String> _processedReminderIds = [];
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initializeReminderCheck();
  }
 
 Future<void> _initializeNotifications() async {
  tz_data.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
      // Handle iOS notification when app is in foreground
    },
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await _flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      final String? payload = notificationResponse.payload;
      if (payload != null) {
        // Handle notification tap
        debugPrint('Notification payload: $payload');
        // You can navigate to task details page here if needed
        _handleNotificationTap(payload);
      }
    },
  );

  // Request permission for iOS devices
  await _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  // Request permission for Android devices (Android 13 and higher)
await _flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
}
  
  @override
  void dispose() {
    _reminderTimer?.cancel();
    _taskNameController.dispose();
    _taskDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (_taskNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task name cannot be empty')),
      );
      return;
    }

    try {
      // Convert the reminders to a format suitable for Firestore
      List<Map<String, dynamic>> remindersList = [];
      for (var reminder in _reminders) {
        remindersList.add({
          'time': '${reminder.hour}:${reminder.minute}',
          'isEnabled': true,
        });
      }
      
      await _firestore.collection('projectTasks').add({
        'name': _taskNameController.text.trim(),
        'description': _taskDescriptionController.text.trim(),
        'date': Timestamp.fromDate(_selectedDate),
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'projectId': widget.projectId, // Link to the project
        'reminders': remindersList,
      });

      _taskNameController.clear();
      _taskDescriptionController.clear();
      _reminders.clear(); // Clear the reminders list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task added successfully'),
            backgroundColor: Colors.blue.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding task: $e'),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteTask(String docId) async {
    try {
      await _firestore.collection('projectTasks').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted successfully'),
            backgroundColor: Colors.blue.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting task: $e'),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _initializeReminderCheck() {
    // Cancel any existing timer
    _reminderTimer?.cancel();
    
    // Check for reminders every minute
    _reminderTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForDueReminders();
    });
    
    // Also check immediately
    _checkForDueReminders();
  }

  Future<void> _checkForDueReminders() async {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('projectTasks')
          .where('projectId', isEqualTo: widget.projectId)
          .get();
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final isCompleted = data['isCompleted'] ?? false;
        
        // Skip completed tasks
        if (isCompleted) continue;
        
        // Check if task is due today
        final taskDate = (data['date'] as Timestamp).toDate();
        final isSameDay = taskDate.year == now.year && 
                          taskDate.month == now.month && 
                          taskDate.day == now.day;
                          
        if (!isSameDay) continue;
        
        // Check reminders
        if (data['reminders'] != null && data['reminders'] is List) {
          for (var reminderItem in data['reminders']) {
            if (reminderItem is Map<String, dynamic>) {
              final timeString = reminderItem['time'] as String;
              final isEnabled = reminderItem['isEnabled'] as bool;
              
              if (!isEnabled) continue;
              
              final timeParts = timeString.split(':');
              if (timeParts.length == 2) {
                final reminderHour = int.tryParse(timeParts[0]) ?? 0;
                final reminderMinute = int.tryParse(timeParts[1]) ?? 0;
                
                // Generate a unique ID for this reminder instance
                final String reminderId = '${doc.id}_${timeString}_${now.day}${now.month}${now.year}';
                final int notificationId = reminderId.hashCode;
                
                // Check if time matches (or is within the last minute) and hasn't been processed
                if (reminderHour == currentHour && 
                    reminderMinute == currentMinute && 
                    !_processedReminderIds.contains(reminderId)) {
                  
                  // Mark as processed
                  _processedReminderIds.add(reminderId);
                  
                  // Show notification
                  await _showTaskNotification(
                    notificationId,
                    '${widget.projectName}: ${data['name'] ?? 'Task Reminder'}',
                    data['description'] ?? 'It\'s time for your scheduled project task',
                    doc.id
                  );
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking reminders: $e');
    }
  }

  Future<void> _showTaskNotification(
    int id, 
    String title, 
    String body, 
    String payload
  ) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'project_task_reminders_channel',
      'Project Task Reminders',
      channelDescription: 'Notifications for scheduled project task reminders',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF0D47A1),
      enableLights: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> _toggleTaskCompletion(String docId, bool currentStatus) async {
    try {
      await _firestore.collection('projectTasks').doc(docId).update({
        'isCompleted': !currentStatus,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $e'),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  void _handleNotificationTap(String taskId) async {
    try {
      // Get task document
      final docSnapshot = await _firestore.collection('projectTasks').doc(taskId).get();
      if (docSnapshot.exists) {
        if (mounted) {
          _showTaskDetails(docSnapshot);
        }
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  void _showTaskDetails(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isCompleted = data['isCompleted'] ?? false;
    final date = (data['date'] as Timestamp).toDate();
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(date);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF0A1829),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000), // 20% black
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0x80808080), // 50% grey
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
              ),
            ),
            
            // Task status indicator with menu
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0x3300CC66) : const Color(0x33FF9900), // 20% green or orange
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCompleted ? 'Completed' : 'In Progress',
                      style: TextStyle(
                        color: isCompleted ? Colors.green.shade300 : Colors.orange.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.pop(context);
                        _editTask(doc);
                      } else if (value == 'reminder') {
                        Navigator.pop(context);
                        _setTaskReminders(doc);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Edit Task'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'reminder',
                        child: Row(
                          children: [
                            Icon(Icons.alarm, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Set Reminders'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Task title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      data['name'] ?? 'Untitled Task',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: isCompleted,
                    onChanged: (bool? value) {
                      _toggleTaskCompletion(doc.id, isCompleted);
                      Navigator.pop(context);
                    },
                    checkColor: Colors.white,
                    activeColor: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            
            // Date info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x4D0D47A1), // 30% of blue.shade900
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xB3FFFFFF)), // 70% white
                  const SizedBox(width: 12),
                  const Text(
                    'Due Date:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xB3FFFFFF), // 70% white
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xB3FFFFFF), // 70% white
                    ),
                  ),
                ],
              ),
            ),
            
            // Reminders info (if set)
            if (data['reminders'] != null && (data['reminders'] as List).isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x4D0D47A1), // 30% of blue.shade900
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.alarm, color: Color(0xB3FFFFFF)), // 70% white
                        SizedBox(width: 12),
                        Text(
                          'Reminders:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xB3FFFFFF), // 70% white
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...(data['reminders'] as List).map((reminder) {
                      // Convert to Map to access properties
                      final reminderMap = reminder as Map<String, dynamic>;
                      final timeString = reminderMap['time'] as String;
                      final isEnabled = reminderMap['isEnabled'] as bool;
                      
                      // Format the time string
                      String formattedTime = 'Not set';
                      final timeParts = timeString.split(':');
                      if (timeParts.length == 2) {
                        int hour = int.tryParse(timeParts[0]) ?? 0;
                        int minute = int.tryParse(timeParts[1]) ?? 0;
                        
                        // Format the time in 12-hour format
                        String period = hour >= 12 ? 'PM' : 'AM';
                        int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                        String minuteStr = minute.toString().padLeft(2, '0');
                        formattedTime = '$displayHour:$minuteStr $period';
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(left: 24, top: 4, bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              isEnabled ? Icons.circle : Icons.circle_outlined,
                              size: 12,
                              color: isEnabled ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xB3FFFFFF), // 70% white
                                fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            
            // Description
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0x0DFFFFFF), // 5% white
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        data['description'] != null && data['description'].toString().isNotEmpty
                            ? data['description']
                            : 'No description provided',
                        style: TextStyle(
                          color: data['description'] != null && data['description'].toString().isNotEmpty
                              ? const Color(0xB3FFFFFF) // 70% white
                              : const Color(0x4DFFFFFF), // 30% white
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _deleteTask(doc.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ), 
          ],
        ),
      ),
    );
  }
  
  void _editTask(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final titleController = TextEditingController(text: data['name']);
    final descriptionController = TextEditingController(text: data['description']);
    DateTime selectedDate = (data['date'] as Timestamp).toDate();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF0A1829),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0x80808080), // 50% grey
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Edit Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty) {
                          FirebaseFirestore.instance.collection('projectTasks').doc(doc.id).update({
                            'name': titleController.text.trim(),
                            'description': descriptionController.text.trim(),
                            'date': Timestamp.fromDate(selectedDate),
                            'updatedAt': Timestamp.now(),
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task updated successfully')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task title cannot be empty')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title input
                      const Text(
                        'Task Title',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0x1AFFFFFF), // 10% white
                          hintText: 'Enter task title',
                          hintStyle: const TextStyle(color: Color(0x80FFFFFF)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Date picker
                      const Text(
                        'Due Date',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        // Inside the _editTask function, replace the date picker part with this:
                      onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate.isBefore(DateTime.now()) ? DateTime.now() : selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Colors.blue,
                                onPrimary: Colors.white,
                                surface: Color(0xFF0A1829),
                                onSurface: Colors.white,
                              ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF0A1829)),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != selectedDate && mounted) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0x1AFFFFFF), // 10% white
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('EEE, MMM d, yyyy').format(selectedDate),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(Icons.calendar_today, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Description input
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 5,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0x1AFFFFFF), // 10% white
                          hintText: 'Enter task description (optional)',
                          hintStyle: const TextStyle(color: Color(0x80FFFFFF)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
  }
  
  void _setTaskReminders(DocumentSnapshot doc) {
  List<TimeOfDay> reminders = [];

  if (doc['reminders'] != null && doc['reminders'] is List) {
    for (var item in doc['reminders']) {
      if (item is Map<String, dynamic> && item.containsKey('time')) {
        final timeParts = (item['time'] as String).split(':');
        if (timeParts.length == 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          reminders.add(TimeOfDay(hour: hour, minute: minute));
        }
      }
    }
  }

  List<TimeOfDay> editedReminders = List<TimeOfDay>.from(reminders);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0A1829),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setStateSheet) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    const Text(
                      'Set Reminders',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.white),
                      onPressed: () {
                        List<Map<String, dynamic>> remindersList = [];
                        for (var reminder in editedReminders) {
                          remindersList.add({
                            'time': '${reminder.hour}:${reminder.minute}',
                            'isEnabled': true,
                          });
                        }
                        Navigator.of(context).pop();
                        _updateTaskReminders(doc.id, remindersList);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (editedReminders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'No reminders set',
                      style: TextStyle(color: Color(0xB3FFFFFF)),
                    ),
                  ),
                ListView.builder(
                  itemCount: editedReminders.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      color: const Color(0x4D0D47A1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          'Reminder ${index + 1}: ${editedReminders[index].format(context)}',
                          style: const TextStyle(color: Color(0xB3FFFFFF)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.access_time,
                                  color: Colors.blue.shade300),
                              onPressed: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: editedReminders[index],
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.dark().copyWith(
                                        colorScheme: ColorScheme.dark(
                                          primary: Colors.blue.shade800,
                                          onPrimary: Colors.white,
                                          surface: const Color(0xFF142238),
                                          onSurface: Colors.white,
                                        ),
                                        dialogTheme: DialogTheme(
                                            backgroundColor:
                                                const Color(0xFF0A1829)),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setStateSheet(() {
                                    editedReminders[index] = picked;
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: Colors.red.shade300),
                              onPressed: () {
                                setStateSheet(() {
                                  editedReminders.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextButton.icon(
                    icon: Icon(Icons.add_alarm, color: Colors.blue.shade300),
                    label: const Text('Add Reminder',
                        style: TextStyle(color: Color(0xB3FFFFFF))),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0x4D0D47A1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: Colors.blue.shade800,
                                onPrimary: Colors.white,
                                surface: const Color(0xFF142238),
                                onSurface: Colors.white,
                              ),
                              dialogTheme: DialogTheme(
                                  backgroundColor:
                                      const Color(0xFF0A1829)),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setStateSheet(() {
                          editedReminders.add(picked);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      );
    },
  );
}


  Future<void> _updateTaskReminders(String docId, List<Map<String, dynamic>> remindersList) async {
  try {
    // Update the document in Firestore
    await _firestore.collection('projectTasks').doc(docId).update({
      'reminders': remindersList,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reminders updated successfully'),
          backgroundColor: Colors.blue.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating reminders: $e'),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

   Future<void> _showAddTaskDialog() async {
    _taskNameController.clear();
    _taskDescriptionController.clear();
    _selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFF142238),
          child: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Add New Task',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade300,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _taskNameController,
                          decoration: InputDecoration(
                            labelText: 'Task Name',
                            labelStyle: TextStyle(color: Colors.blue.shade200),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
                            ),
                            filled: true,
                            fillColor: const Color(0x0DFFFFFF), // 5% white
                            prefixIcon: Icon(Icons.task, color: Colors.blue.shade300),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade700),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _taskDescriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description (Optional)',
                            labelStyle: TextStyle(color: Colors.blue.shade200),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
                            ),
                            filled: true,
                            fillColor: const Color(0x0DFFFFFF), // 5% white
                            prefixIcon: Icon(Icons.description, color: Colors.blue.shade300),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade700),
                            ),
                          ),
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          color: const Color(0x4D0D47A1), // 30% of blue.shade900
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(
                              'Due Date: ${DateFormat('EEE, MMM d, yyyy').format(_selectedDate)}',
                              style: const TextStyle(color: Color(0xB3FFFFFF)), // 70% white
                            ),
                            trailing: Icon(Icons.calendar_today, color: Colors.blue.shade300),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: Colors.blue.shade800,
                                        onPrimary: Colors.white,
                                        surface: const Color(0xFF142238),
                                        onSurface: Colors.white,
                                      ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF0A1829)),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                            title: const Text('Set Reminders', style: TextStyle(color: Color(0xB3FFFFFF))), // 70% white
                            value: _reminders.isNotEmpty,
                            activeColor: Colors.blue.shade300,
                            onChanged: (bool value) {
                              setStateDialog(() {
                                if (value && _reminders.isEmpty) {
                                  // Add default reminder if turning on and no reminders exist
                                  _reminders.add(TimeOfDay.now());
                                } else if (!value) {
                                  // Clear all reminders if turning off
                                  _reminders.clear();
                                }
                              });
                            },
                            secondary: Icon(Icons.alarm, color: Colors.blue.shade300),
                          ),
                          if (_reminders.isNotEmpty)
                            Column(
                              children: [
                                // List of existing reminders
                                ..._reminders.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  TimeOfDay reminder = entry.value;
                                  
                                  return Card(
                                    elevation: 2,
                                    color: const Color(0x4D0D47A1), // 30% of blue.shade900
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(
                                        'Reminder ${index + 1}: ${reminder.format(context)}',
                                        style: const TextStyle(color: Color(0xB3FFFFFF)), // 70% white
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.access_time, color: Colors.blue.shade300),
                                            onPressed: () async {
                                              final TimeOfDay? picked = await showTimePicker(
                                                context: context,
                                                initialTime: reminder,
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: ThemeData.dark().copyWith(
                                                      colorScheme: ColorScheme.dark(
                                                        primary: Colors.blue.shade800,
                                                        onPrimary: Colors.white,
                                                        surface: const Color(0xFF142238),
                                                        onSurface: Colors.white,
                                                      ),
                                                      dialogTheme: DialogTheme(backgroundColor: const Color(0xFF0A1829)),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );
                                              if (picked != null) {
                                                setStateDialog(() {
                                                  _reminders[index] = picked;
                                                });
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red.shade300),
                                            onPressed: () {
                                              setStateDialog(() {
                                                _reminders.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                
                                // Add new reminder button
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: TextButton.icon(
                                    icon: Icon(Icons.add_alarm, color: Colors.blue.shade300),
                                    label: const Text('Add Another Reminder', 
                                      style: TextStyle(color: Color(0xB3FFFFFF))),
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0x4D0D47A1),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    ),
                                    onPressed: () async {
                                      final TimeOfDay? picked = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        builder: (context, child) {
                                          return Theme(
                                            data: ThemeData.dark().copyWith(
                                              colorScheme: ColorScheme.dark(
                                                primary: Colors.blue.shade800,
                                                onPrimary: Colors.white,
                                                surface: const Color(0xFF142238),
                                                onSurface: Colors.white,
                                              ),
                                              dialogTheme: DialogTheme(backgroundColor: const Color(0xFF0A1829)),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setStateDialog(() {
                                          _reminders.add(picked);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel', style: TextStyle(color: Colors.blue.shade300)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close dialog immediately
                          await _addTask();            // Then run async task
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('Add Task'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF081221),
        title: Text(
          widget.projectName,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF081221), // Very dark blue
              Color(0xFF0A1829), // Dark blue
              Color(0xFF142238), // Slightly lighter dark blue
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('projectTasks')
              .where('projectId', isEqualTo: widget.projectId)
              .orderBy('date')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.task_alt,
                      size: 80,
                      color: Color(0x4DFFFFFF), // 30% white
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tasks found',
                      style: TextStyle(
                        color: Color(0x80FFFFFF), // 50% white
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showAddTaskDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Create your first task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            //copy here
              Map<String, List<DocumentSnapshot>> groupedTasks = {};

                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final date = (data['date'] as Timestamp).toDate();
                      final dateStr = DateFormat('EEE, MMM d, yyyy').format(date);

                      groupedTasks[dateStr] = groupedTasks[dateStr] ?? [];
                      groupedTasks[dateStr]!.add(doc);
                    }

                    List<Widget> dateGroups = [];

                    groupedTasks.forEach((dateStr, tasks) {
                      // Add date header
                      // dateGroups.add(
                      //   Container(
                      //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      //     decoration: BoxDecoration(
                      //       color: const Color(0x4D0D47A1), // 30% of blue.shade900
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     child: const Row(
                      //       children: [
                      //         Icon(Icons.date_range, color: Color(0xB3FFFFFF)), // 70% white
                      //         SizedBox(width: 8),
                      //         Text(
                      //           'Date',
                      //           style: TextStyle(
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.bold,
                      //             color: Color(0xB3FFFFFF), // 70% white
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // );
                      
                      // Date text
                      dateGroups.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                          child: Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xB3FFFFFF), // 70% white
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );

                      // Add tasks under this date
                      for (var doc in tasks) {
                        final data = doc.data() as Map<String, dynamic>;
                        final isCompleted = data['isCompleted'] ?? false;

                        dateGroups.add(
                          Dismissible(
                            key: Key(doc.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade900,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _deleteTask(doc.id),
                            child: GestureDetector(
                              onTap: () => _showTaskDetails(doc),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCompleted 
                                      ? const Color(0x330D47A1) // 20% blue.shade900
                                      : const Color(0x0FFFFFFF), // 6% white
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCompleted 
                                        ? const Color(0x330D47A1) // 20% blue.shade800
                                        : const Color(0x0FFFFFFF), // 6% white
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    data['name'] ?? 'Untitled Task',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration: isCompleted 
                                          ? TextDecoration.lineThrough 
                                          : null,
                                      color: isCompleted 
                                          ? Colors.grey 
                                          : Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  leading: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCompleted 
                                          ? const Color(0x3300CC66) // 20% green
                                          : const Color(0x33FF9900), // 20% orange
                                      border: Border.all(
                                        color: isCompleted 
                                            ? Colors.green.shade300 
                                            : Colors.orange.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isCompleted 
                                        ? Icon(Icons.check, color: Colors.green.shade300, size: 16) 
                                        : null,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                    if (data['reminders'] != null && (data['reminders'] as List).isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Icons.notifications_active,
                                          size: 16,
                                          color: Colors.blue.shade300,
                                        ),
                                      ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.blue.shade300,
                                    ),
                                  ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    });
                    return ListView(
                      padding: const EdgeInsets.only(bottom: 80),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: dateGroups, // Fix for scrolling issue
                    );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


                    
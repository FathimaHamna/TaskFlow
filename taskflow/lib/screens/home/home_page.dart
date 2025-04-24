import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import '../tasks/task_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Toggle state for task type
  bool _showDailyTasks = true;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    // Create streams for both task types
    final Stream<QuerySnapshot> todayDailyTasksStream = FirebaseFirestore.instance
        .collection('tasks')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .snapshots();

    final Stream<QuerySnapshot> todayProjectTasksStream = FirebaseFirestore.instance
        .collection('projectTasks')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .snapshots();

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
          child: StreamBuilder<QuerySnapshot>(
            stream: _showDailyTasks ? todayDailyTasksStream : todayProjectTasksStream,
            builder: (context, snapshot) {
              final totalTasks = snapshot.data?.docs.length ?? 0;
              final completedTasks = snapshot.data?.docs
                      .where((doc) => (doc['isCompleted'] ?? false) == true)
                      .length ??
                  0;
              final completionRatio =
                  totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

              return SizedBox(
                // This ensures the content takes full height
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Section without container
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage('assets/images/profile.png'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Hello !!!',
                                      style: TextStyle(
                                        color: Colors.blue.shade100,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      CupertinoIcons.hand_raised_fill,
                                      color: Colors.blue.shade200,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    "How's your day?",
                                    style: TextStyle(
                                    color: Colors.blue.shade200.withAlpha(179), // ~70% opacity
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Date section 
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0x4D0D47A1), // 30% of blue.shade900
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.calendar,
                                  color: Colors.blue.shade200,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy').format(now),
                                  style: const TextStyle(
                                    color: Color(0xB3FFFFFF), // 70% white
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Today's Focus Card with task theme
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade900, Colors.blue.shade800],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.15 * 255).round()),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.flag_fill,
                                    color: Colors.blue.shade200,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Today's Focus",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Stack(
                                children: [
                                  Container(
                                    height: 12,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha((0.3 * 255).round()),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  Container(
                                    height: 12,
                                    width: MediaQuery.of(context).size.width * completionRatio * 0.8,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.blue.shade300, Colors.blue.shade100],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.shade100.withAlpha((0.5 * 255).round()),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$completedTasks of $totalTasks tasks completed',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${(completionRatio * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Today's Tasks Title with icon and toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.list_bullet,
                                  color: Colors.blue.shade300,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Today's Tasks",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Toggle switch
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x4D0D47A1), // 30% of blue.shade900
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildToggleButton(
                                    label: "Daily",
                                    isSelected: _showDailyTasks,
                                    onTap: () {
                                      if (!_showDailyTasks) {
                                        setState(() {
                                          _showDailyTasks = true;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _buildToggleButton(
                                    label: "Projects",
                                    isSelected: !_showDailyTasks,
                                    onTap: () {
                                      if (_showDailyTasks) {
                                        setState(() {
                                          _showDailyTasks = false;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Task List with enhanced design
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        else if (snapshot.hasError)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Column(
                                children: [
                                  Icon(
                                    CupertinoIcons.exclamationmark_circle,
                                    color: Colors.red.shade300,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Error: ${snapshot.error}',
                                    style: TextStyle(color: Colors.red.shade200),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (totalTasks == 0)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.task_alt,
                                    color: const Color(0x4DFFFFFF), // 30% white
                                    size: 50,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No ${_showDailyTasks ? 'daily' : 'project'} tasks for today',
                                    style: const TextStyle(
                                      color: Color(0x80FFFFFF), // 50% white
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Enjoy your free time!',
                                    style: TextStyle(
                                      color: Colors.blue.shade300,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final doc = snapshot.data!.docs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final isCompleted = data['isCompleted'] ?? false;

                              return GestureDetector(
                                onTap: () {
                                // Navigate to task details
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TaskDetailPage(
                                      taskId: doc.id,
                                      isProjectTask: !_showDailyTasks,
                                    ),
                                  ),
                                );
                              },
                                  child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
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
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
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
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      color: Colors.blue.shade300,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper method to build toggle buttons
  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade700 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue.shade200,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// This class is just a placeholder for where you would navigate to when a task is tapped
// You'll need to implement this page based on your task detail requirements
// class TaskDetailPage extends StatelessWidget {
//   final String taskId;
//   final bool isProjectTask;

//   const TaskDetailPage({
//     super.key,
//     required this.taskId,
//     required this.isProjectTask,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isProjectTask ? 'Project Task Details' : 'Task Details'),
//       ),
//       body: Center(
//         child: Text('Details for ${isProjectTask ? 'project' : 'daily'} task: $taskId'),
//       ),
//     );
//   }
// }
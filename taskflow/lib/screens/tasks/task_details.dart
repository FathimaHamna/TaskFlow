import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Changed to StatefulWidget to manage completion state
class TaskDetailPage extends StatefulWidget {
  final String taskId;
  final bool isProjectTask;

  const TaskDetailPage({
    super.key,
    required this.taskId,
    required this.isProjectTask,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  // Local state to track task completion status
  bool? _isCompleted;
  
  @override
  Widget build(BuildContext context) {
    // Determine which collection to query based on task type
    final String collectionPath = widget.isProjectTask ? 'projectTasks' : 'tasks';
    
    return Scaffold(
      body: Container(
        // Make container take full height of the screen
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
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
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection(collectionPath)
                .doc(widget.taskId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_circle,
                        color: Colors.red.shade300,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Error loading task: ${snapshot.error}',
                        style: TextStyle(color: Colors.red.shade200),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text(
                    'Task not found',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final title = data['name'] ?? 'Untitled Task';
              final description = data['description'] != null && data['description'].toString().trim().isNotEmpty 
    ? data['description'] 
    : 'No description available';
              
              // Initialize our local state with the value from Firebase
              // Only update if it hasn't been set yet or we're forcing a refresh
              _isCompleted ??= data['isCompleted'] ?? false;
              
              // For project tasks, fetch the project name from 'projects' collection
              if (widget.isProjectTask) {
                final projectId = data['projectId'];
                if (projectId != null) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('projects')
                        .doc(projectId)
                        .get(),
                    builder: (context, projectSnapshot) {
                      String projectName = 'Unknown Project';
                      
                      if (projectSnapshot.hasData && projectSnapshot.data!.exists) {
                        final projectData = projectSnapshot.data!.data() as Map<String, dynamic>;
                        projectName = projectData['name'] ?? 'Unknown Project';
                      }
                      
                      return _buildTaskDetails(
                        context,
                        title,
                        description,
                        collectionPath,
                        projectName,
                      );
                    },
                  );
                }
              }
              
              // For regular tasks or if no project ID is available
              return _buildTaskDetails(
                context,
                title, 
                description,
                collectionPath,
                null,
              );
            },
          ),
        ),
      ),
    );
  }
  
  // Method to toggle completion status
  void _toggleCompletionStatus(String collectionPath) {
    // First update local state immediately for UI responsiveness
    setState(() {
      _isCompleted = !(_isCompleted ?? false);
    });
    
    // Then update Firebase
    FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(widget.taskId)
        .update({
      'isCompleted': _isCompleted,
    }).then((_) {
      // Show snackbar confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isCompleted! ? 'Task marked as complete' : 'Task marked as incomplete',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      // Revert local state if Firebase update fails
      setState(() {
        _isCompleted = !(_isCompleted ?? false);
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update task: $error',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
  
  Widget _buildTaskDetails(
    BuildContext context,
    String title,
    String description,
    String collectionPath,
    String? projectName,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Task Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Complete/Incomplete toggle button - Now uses local state
                IconButton(
                  icon: Icon(
                    _isCompleted == true
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.circle,
                    color: _isCompleted == true
                        ? Colors.green.shade300
                        : Colors.blue.shade300,
                  ),
                  onPressed: () => _toggleCompletionStatus(collectionPath),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Task Status Indicator - Now uses local state
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isCompleted == true
                    ? const Color(0x3300CC66) // 20% green
                    : const Color(0x33FF9900), // 20% orange
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isCompleted == true
                        ? Icons.check_circle_outline
                        : Icons.pending_outlined,
                    color: _isCompleted == true
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isCompleted == true ? 'Completed' : 'In Progress',
                    style: TextStyle(
                      color: _isCompleted == true
                          ? Colors.green.shade300
                          : Colors.orange.shade300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Task Title
            const Text(
              'Task Title',
              style: TextStyle(
                color: Color(0x80FFFFFF),  // 50% white
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),  // 10% white
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0x1AFFFFFF),  // 10% white
                  width: 1,
                ),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  decoration: _isCompleted == true ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Project Name (Only for project tasks)
            if (widget.isProjectTask && projectName != null) ...[
              const Text(
                'Project',
                style: TextStyle(
                  color: Color(0x80FFFFFF),  // 50% white
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),  // 10% white
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0x1AFFFFFF),  // 10% white
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.folder_fill,
                      color: Colors.blue.shade300,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      projectName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Task Description
            const Text(
              'Description',
              style: TextStyle(
                color: Color(0x80FFFFFF),  // 50% white
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),  // 10% white
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0x1AFFFFFF),  // 10% white
                  width: 1,
                ),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  color: Color(0xCCFFFFFF),  // 80% white
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            
            // Add extra padding at the bottom for better scrolling experience
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
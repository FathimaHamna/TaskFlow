import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> notesStream = FirebaseFirestore.instance
        .collection('notes')
        .orderBy('createdAt', descending: true)
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
            stream: notesStream,
            builder: (context, snapshot) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Section
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Your Digital Note Book',
                                        style: TextStyle(
                                          color: Colors.blue.shade100,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Icon(
                                        CupertinoIcons.doc_text_fill,
                                        color: Colors.blue.shade200,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Capture your thoughts',
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
                                    DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
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

                          // Notes Stats Card
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
                                      CupertinoIcons.square_stack_fill,
                                      color: Colors.blue.shade200,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Notes Overview",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          snapshot.data?.docs.length.toString() ?? '0',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Total Notes',
                                          style: TextStyle(
                                            color: Colors.blue.shade200,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 40,
                                      width: 1,
                                      color: Colors.blue.shade700,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          snapshot.data?.docs.isNotEmpty == true ? 
                                            DateFormat('MMM d').format((snapshot.data?.docs.first.data() as Map<String, dynamic>)['createdAt'].toDate()) 
                                            : '-',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Last Added',
                                          style: TextStyle(
                                            color: Colors.blue.shade200,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Notes Title with icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.doc_text_fill,
                                    color: Colors.blue.shade300,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "My Notes",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => _showAddNoteDialog(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Colors.blue.shade100,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Add',
                                        style: TextStyle(
                                          color: Colors.blue.shade100,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Notes List
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  else if (snapshot.hasError)
                    SliverFillRemaining(
                      child: Center(
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
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.red.shade200),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (snapshot.data?.docs.isEmpty ?? true)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.doc_text,
                              color: const Color(0x4DFFFFFF), // 30% white
                              size: 50,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No notes yet',
                              style: TextStyle(
                                color: Color(0x80FFFFFF), // 50% white
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Tap "Add" to create your first note',
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
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final title = data['title'] ?? 'Untitled Note';
                            final content = data['content'] ?? '';
                            final createdAt = data['createdAt'] != null
                                ? (data['createdAt'] as Timestamp).toDate()
                                : DateTime.now();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0x0FFFFFFF), // 6% white
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0x0FFFFFFF), // 6% white
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      content,
                                      style: TextStyle(
                                        color: Colors.grey.shade300,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.time,
                                          color: Colors.blue.shade300,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('MMM d, yyyy · h:mm a').format(createdAt),
                                          style: TextStyle(
                                            color: Colors.blue.shade200,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.blue.shade300,
                                  ),
                                  color: const Color(0xFF142238),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Colors.blue.shade300,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Edit',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.red.shade300,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditNoteDialog(context, doc.id, title, content);
                                    } else if (value == 'delete') {
                                      _showDeleteConfirmation(context, doc.id, title);
                                    }
                                  },
                                ),
                                onTap: () {
                                  _showNoteDetails(context, title, content, createdAt);
                                },
                              ),
                            );
                          },
                          childCount: snapshot.data!.docs.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0A1829),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.doc_text_fill,
                      color: Colors.blue.shade300,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Add New Note',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: const Color(0x1AFFFFFF), // 10% white
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Note content',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: const Color(0x1AFFFFFF), // 10% white
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _titleController.clear();
                        _contentController.clear();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.trim().isNotEmpty) {
                          FirebaseFirestore.instance.collection('notes').add({
                            'title': _titleController.text.trim(),
                            'content': _contentController.text.trim(),
                            'createdAt': Timestamp.now(),
                          });
                          Navigator.pop(context);
                          _titleController.clear();
                          _contentController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditNoteDialog(BuildContext context, String noteId, String title, String content) {
    _titleController.text = title;
    _contentController.text = content;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0A1829),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Colors.blue.shade300,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Edit Note',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: const Color(0x1AFFFFFF), // 10% white
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Note content',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: const Color(0x1AFFFFFF), // 10% white
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _titleController.clear();
                        _contentController.clear();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.trim().isNotEmpty) {
                          FirebaseFirestore.instance.collection('notes').doc(noteId).update({
                            'title': _titleController.text.trim(),
                            'content': _contentController.text.trim(),
                            'updatedAt': Timestamp.now(),
                          });
                          Navigator.pop(context);
                          _titleController.clear();
                          _contentController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String noteId, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A1829),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Delete Note',
            style: TextStyle(color: Colors.red.shade300),
          ),
          content: Text(
            'Are you sure you want to delete "$title"?',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade300),
              ),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('notes').doc(noteId).delete();
                Navigator.pop(context);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red.shade300),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNoteDetails(BuildContext context, String title, String content, DateTime createdAt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A1829),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.doc_text_fill,
                          color: Colors.blue.shade300,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.time,
                          color: Colors.blue.shade300,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('MMMM d, yyyy • h:mm a').format(createdAt),
                          style: TextStyle(
                            color: Colors.blue.shade200,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF), // 10% white
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        content.isEmpty ? 'No content' : content,
                        style: TextStyle(
                          color: content.isEmpty ? Colors.grey.shade400 : Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
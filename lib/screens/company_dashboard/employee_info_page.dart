import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pot/ui_elements/task_card.dart';
import 'package:pot/models/task_model.dart'  as model;

import 'DailyReportPage.dart';
import 'VacationPage.dart';
import 'WeeklyHistoryPage.dart';

class EmployeeInfoPage extends StatefulWidget {
  final String userId;

  const EmployeeInfoPage({super.key, required this.userId});

  @override
  State<EmployeeInfoPage> createState() => _EmployeeInfoPageState();
}

class _EmployeeInfoPageState extends State<EmployeeInfoPage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDataFuture;
  final Map<String, TextEditingController> _controllers = {};

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadMessage;
  String? _contractUrl;

  @override
  void initState() {
    super.initState();
    _userDataFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get()
        .then((doc) {
      _contractUrl = doc.data()?['urlContract'];
      return doc;
    });
  }

  final _hiddenFields = ['type', 'createdAt', 'password', 'promoCode'];
  final _readonlyFields = ['name', 'status', 'emailOrPhone', 'workedHours'];

  final _personalFields = ['emailOrPhone', 'contact'];
  final _workFields = [
    'status',
    'position',
    'startDate',
    'endDate',
    'task',
    'workedHours',
    'weeklyHours',
    'workSchedule',
    'salary',
  ];

  Future<void> _saveChanges() async {
    final Map<String, dynamic> updatedData = {};

    _controllers.forEach((key, controller) {
      if (!_readonlyFields.contains(key)) {
        updatedData[key] = controller.text.isNotEmpty
            ? controller.text
            : key == 'salary'
            ? '0'
            : '';
      }
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully ✅')),
    );
  }

  Future<void> _uploadContract() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) {
        setState(() {
          _isUploading = false;
          _uploadMessage = '❌ Upload canceled';
        });
        return;
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _uploadMessage = null;
      });

      Uint8List fileBytes = result.files.single.bytes!;
      final fileName = '${widget.userId}_contract.pdf';
      final ref = FirebaseStorage.instance.ref().child('contracts/$fileName');

      final uploadTask = ref.putData(fileBytes);

      uploadTask.snapshotEvents.listen((taskSnapshot) {
        if (taskSnapshot.totalBytes > 0) {
          setState(() {
            _uploadProgress =
                taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
          });
        }
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'urlContract': url});

      setState(() {
        _contractUrl = url;
        _isUploading = false;
        _uploadProgress = 0.0;
        _uploadMessage = '✅ Upload successful';
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
        _uploadMessage = '❌ Error: $e';
      });
    }
  }

  Future<void> _previewContract() async {
    if (_contractUrl == null) return;
    final uri = Uri.parse(_contractUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open contract.')),
      );
    }
  }

  Future<void> _downloadContract() async {
    if (_contractUrl == null) return;
    final uri = Uri.parse(_contractUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildField(String key, String value,
      {String? defaultValue, String? hintText}) {
    final readOnly = _readonlyFields.contains(key);
    final controller = _controllers.putIfAbsent(
      key,
          () =>
          TextEditingController(text: value.isNotEmpty ? value : (defaultValue ?? '')),
    );

    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: key == 'salary' ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: key.replaceAll('_', ' ').toUpperCase(),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: hintText,
      ),
    );
  }

  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final statusController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final dueDateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Task'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: statusController, decoration: const InputDecoration(labelText: 'Status')),
              TextField(controller: startDateController, decoration: const InputDecoration(labelText: 'Start Date')),
              TextField(controller: endDateController, decoration: const InputDecoration(labelText: 'End Date')),
              TextField(controller: dueDateController, decoration: const InputDecoration(labelText: 'Due Date')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final task = model.Task(
                id: '',
                title: titleController.text.isEmpty ? '-' : titleController.text,
                description: descriptionController.text.isEmpty ? '-' : descriptionController.text,
                status: statusController.text.isEmpty ? '-' : statusController.text,
                startDate: startDateController.text.isEmpty ? '-' : startDateController.text,
                endDate: endDateController.text.isEmpty ? '-' : endDateController.text,
                dueDate: dueDateController.text.isEmpty ? '-' : dueDateController.text,
              );

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection('tasks')
                  .add(task.toMap());

              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Employee Information'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('User not found.'));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred.'));
          }

          final userData = snapshot.data!.data()!;
          final name = userData['name'] ?? 'Unknown';
          final photoUrl = userData['photoUrl'] ??
              'https://ui-avatars.com/api/?name=$name&background=1976D2&color=fff';

          _hiddenFields.forEach(userData.remove);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(photoUrl),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('👤 Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._personalFields
                    .where((f) => userData.containsKey(f))
                    .map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildField(f, userData[f].toString()),
                )),
                const SizedBox(height: 30),
                const Text('💼 Work Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._workFields.map((f) {
                  if (f == 'workSchedule') {
                    final scheduleText = (userData[f]?.toString().isNotEmpty ?? false)
                        ? userData[f].toString()
                        : '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _buildField(
                        f,
                        scheduleText,
                        hintText: 'Mon-Fri 09:00-18:00',
                      ),
                    );
                  } else if (f == 'salary') {
                    final salaryText = (userData[f]?.toString().isNotEmpty ?? false)
                        ? userData[f].toString()
                        : '0';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _buildField(f, salaryText),
                    );
                  } else if (userData.containsKey(f)) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _buildField(f, userData[f].toString()),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }).toList(),
                const SizedBox(height: 30),

                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    '🗂 Tasks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .collection('tasks')
                      .orderBy('startDate', descending: true)
                      .snapshots(),
                  builder: (context, taskSnapshot) {
                    if (!taskSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final tasks = taskSnapshot.data!.docs
                        .map((doc) => model.Task.fromMap(doc.id, doc.data()))
                        .toList();
                    final showTasks = tasks.length > 3 ? tasks.sublist(0, 3) : tasks;

                    return Column(
                      children: [
                        ...showTasks.map((task) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9, // ширина карточки 90% экрана
                              child: TaskCard(task: task),
                            ),
                          ),
                        )),
                        if (tasks.length > 3)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AllTasksPage(userId: widget.userId),
                                ),
                              );
                            },
                            child: const Text('All Tasks'),
                          ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _showAddTaskDialog,
                          child: const Text('Add Task'),
                        ),
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WeeklyHistoryPage(userId: widget.userId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month, color: Colors.white),
                          label: const Text('History of last week', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DailyReportPage(userId: widget.userId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month, color: Colors.white),
                          label: const Text('Daily Report', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VacationPage(userId: widget.userId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.beach_access, color: Colors.white),
                          label: const Text('Vacations', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),



                      ],
                    );
                  },
                ),


                const SizedBox(height: 30),
                const Center(child: Text('📑 Employment Contract', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                const SizedBox(height: 16),
                Center(
                  child: _isUploading
                      ? Column(
                    children: [
                      CircularProgressIndicator(
                        value: _uploadProgress > 0 ? _uploadProgress : null,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (_uploadMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _uploadMessage!,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ],
                  )
                      : _contractUrl == null
                      ? ElevatedButton.icon(
                    onPressed: _uploadContract,
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text('Upload Contract', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                      : Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _previewContract,
                        icon: const Icon(Icons.visibility, color: Colors.white),
                        label: const Text('Preview Contract', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _downloadContract,
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text('Download Contract', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      if (_uploadMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _uploadMessage!,
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade500,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Action'),
                          content: const Text(
                            'Are you sure you want to end cooperation with this employee?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userId)
                              .update({'promoCode': null});

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cooperation ended successfully.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.stop_circle, color: Colors.white),
                    label: const Text(
                      'End Cooperation',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

              ],
            ),
          );
        },
      ),
    );
  }
}


class AllTasksPage extends StatefulWidget {
  final String userId;

  const AllTasksPage({super.key, required this.userId});

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  bool showCompleted = false; // false = show not completed, true = show completed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
      ),
      body: Column(
        children: [
          // Switch для фильтрации
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Show Completed Tasks'),
                Switch(
                  value: showCompleted,
                  onChanged: (val) {
                    setState(() {
                      showCompleted = val;
                    });
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection('tasks')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!.docs
                    .map((doc) => model.Task.fromMap(doc.id, doc.data()))
                    .where((task) {
                  if (showCompleted) {
                    return task.status.toLowerCase() == 'completed';
                  } else {
                    return task.status.toLowerCase() != 'completed';
                  }
                })
                    .toList();

                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks to show.'));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final t = tasks[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(t.title),
                        subtitle: Text('Description: ${t.description}\n'
                            'Status: ${t.status}\n'
                            'Start: ${t.startDate} - End: ${t.endDate}\n'
                            'Due: ${t.dueDate}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}


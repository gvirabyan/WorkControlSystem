import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pot/ui_elements/task_card.dart';
import 'package:pot/models/task_model.dart' as model;
// НОВЫЙ ИМПОРТ: Замените на путь к вашему файлу RequestVacationPage
import 'request_vacation_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.userId,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDataFuture;

  final _personalFields = ['emailOrPhone', 'contact'];
  final _workFields = [
    'currentStatus',
    'position',
    'startDate',
    'endDate',
    'task',
    'workedHours',
    'weeklyHours',
    'workSchedule',
    'salary',
  ];

  @override
  void initState() {
    super.initState();
    _userDataFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
  }

  Widget _buildField(String key, String value) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: key.replaceAll('_', ' ').toUpperCase(),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // --- НОВАЯ ФУНКЦИЯ: Обработка нажатия кнопки Отпуск ---
  void _goToVacationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestVacationPage(userId: widget.userId),
      ),
    );
  }
  // --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('My Profile'),
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

          final userData = snapshot.data!.data()!;
          final name = userData['name'] ?? 'Unknown';
          final photoUrl = userData['photoUrl'] ??
              'https://ui-avatars.com/api/?name=$name&background=1976D2&color=fff';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ---- Фото и имя ----
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
                // ---- Личные данные ----
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('👤 Personal Information',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                ..._personalFields
                    .where((f) => userData.containsKey(f))
                    .map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildField(f, userData[f].toString()),
                )),

                const SizedBox(height: 30),
                // ---- Рабочие данные ----
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('💼 Work Information',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),

                ..._workFields
                    .where((f) => userData.containsKey(f))
                    .map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildField(f, userData[f].toString()),
                )),

                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: _goToVacationPage,
                    icon: const Icon(Icons.beach_access),
                    label: const Text('Vacation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    '🗂 My Tasks',
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
                      .limit(3)
                      .snapshots(),
                  builder: (context, taskSnapshot) {
                    if (!taskSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final tasks = taskSnapshot.data!.docs
                        .map((doc) => model.Task.fromMap(doc.id, doc.data()))
                        .toList();

                    if (tasks.isEmpty) {
                      return const Text('No tasks available.');
                    }

                    return Column(
                      children: tasks
                          .map((task) => Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 8.0),
                        child: TaskCard(task: task),
                      ))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // ---- Logout ----
                Center(
                  child: ElevatedButton.icon(
                    onPressed: widget.onLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pot/ui_elements/task_card.dart';
import 'package:pot/models/task_model.dart' as model;
import '../../all_tasks_page.dart';
import '../../company_dashboard/DailyReportPage.dart';
import '../../company_dashboard/WeeklyHistoryPage.dart';
import '../request_vacation_page.dart';
import 'employee_notes_page.dart';

class EmployeeProfilePage extends StatefulWidget {
  final String userId;
  final VoidCallback onLogout;

  const EmployeeProfilePage({
    super.key,
    required this.userId,
    required this.onLogout,
  });

  @override
  State<EmployeeProfilePage> createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
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
                ExpansionTile(
                  title: const Text(
                    '👤 Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  initiallyExpanded: false, // по умолчанию свернуто
                  children:
                  _personalFields
                      .where((f) => userData.containsKey(f))
                      .map(
                        (f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _buildField(f, userData[f].toString()),
                    ),
                  )
                      .toList(),
                ),

                const SizedBox(height: 30),
                // ---- Рабочие данные ----
                ExpansionTile(
                  title: const Text(
                    '💼 Work Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  initiallyExpanded: false, // по умолчанию свернуто
                  children:
                  _workFields.map((f) {
                    if (f == 'workSchedule') {
                      final scheduleText =
                      (userData[f]?.toString().isNotEmpty ?? false)
                          ? userData[f].toString()
                          : '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _buildField(
                          f,
                          scheduleText,
                          //hintText: 'Mon-Fri 09:00-18:00',
                        ),
                      );
                    } else if (f == 'salary') {
                      final salaryText =
                      (userData[f]?.toString().isNotEmpty ?? false)
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
                ),

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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeNotesPage(
                            companyPromoCode: userData['promoCode'] ?? '',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.note_alt),
                    label: const Text('Notes'),
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

               ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllTasksPage(userId: widget.userId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '🗂 Tasks',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 20),

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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
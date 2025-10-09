import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeInfoPage extends StatefulWidget {
  final String userId;

  const EmployeeInfoPage({super.key, required this.userId});

  @override
  State<EmployeeInfoPage> createState() => _EmployeeInfoPageState();
}

class _EmployeeInfoPageState extends State<EmployeeInfoPage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDataFuture;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _userDataFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
  }

  // Список полей, которые не нужно показывать вообще
  final _hiddenFields = ['type', 'createdAt', 'password', 'promoCode'];

  // Поля, которые показываются, но не редактируются
  final _readonlyFields = ['name','status', 'emailOrPhone', 'workedHours'];

  // Группировка на категории
  final _personalFields = [ 'emailOrPhone', 'contact'];
  final _workFields = ['status', 'startDate', 'endDate', 'task', 'workedHours', 'weeklyHours'];

  Future<void> _saveChanges() async {
    final Map<String, dynamic> updatedData = {};
    _controllers.forEach((key, controller) {
      if (!_readonlyFields.contains(key)) {
        updatedData[key] = controller.text;
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

  Widget _buildField(String key, String value) {
    final readOnly = _readonlyFields.contains(key);
    final controller = _controllers.putIfAbsent(
      key,
          () => TextEditingController(text: value),
    );

    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: key.replaceAll('_', ' ').toUpperCase(),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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

          // Удаляем скрытые поля
          _hiddenFields.forEach(userData.remove);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🪪 Аватар и имя
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

                // 👤 Персональные данные
                const Text(
                  '👤 Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._personalFields
                    .where((field) => userData.containsKey(field))
                    .map((field) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildField(field, userData[field].toString()),
                )),

                const SizedBox(height: 30),

                // 🧑‍💻 Информация о работе
                const Text(
                  '💼 Work Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._workFields
                    .where((field) => userData.containsKey(field))
                    .map((field) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildField(field, userData[field].toString()),
                )),

                const SizedBox(height: 30),

                // 💾 Кнопка "Сохранить"
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.blue.shade700,
                    ),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

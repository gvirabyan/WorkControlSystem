import 'package:flutter/material.dart';
import '../models/UserModel.dart';
import '../screens/company_dashboard/employee_info_page.dart';

class UserItem extends StatelessWidget {
  final UserModel user;
  const UserItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeInfoPage(userId: user.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FF), // Светло-голубой фон
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Аватар
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              backgroundImage: user.avatarUrl.isNotEmpty
                  ? NetworkImage(user.avatarUrl)
                  : null,
              child: user.avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 28, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),

            // Информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Имя и фамилия
                  Text(
                    user.name.isNotEmpty ? user.name : '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),

                  // Позиция в компании
                  const SizedBox(height: 4),
                  Text(
                    user.position?.isNotEmpty == true ? user.position! : '-',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
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
}

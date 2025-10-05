import 'package:flutter/material.dart';

import '../models/UserModel.dart';
import '../screens/company_dashboard/employee_info_page.dart';

class UserItem extends StatelessWidget {
  final UserModel user;
  const UserItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        backgroundImage:
        user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
        child: user.avatarUrl.isEmpty
            ? const Icon(Icons.person, size: 24)
            : null,
      ),
      title: Text(user.name),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeInfoPage(userId: user.id),
          ),
        );
      },
    );
  }
}

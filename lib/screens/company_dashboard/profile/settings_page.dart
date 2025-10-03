import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _notificationsEnabled = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            SwitchListTile(
              title: const Text("Enable Notifications"),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 30),
            const Text("Change Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _oldPasswordController,
              decoration: const InputDecoration(labelText: "Old Password"),
              obscureText: true,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: "New Password"),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return "Field required";
                if (value.length < 6) return "Password must be at least 6 characters long";
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: "Confirm New Password"),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return "Field required";
                if (value != _newPasswordController.text) return "Passwords do not match";
                return null;
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Password change logic will go here
                }
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}

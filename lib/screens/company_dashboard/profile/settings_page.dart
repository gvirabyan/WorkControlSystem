import 'package:flutter/material.dart';
import 'package:pot/services/auth_service.dart';
import 'package:pot/ui_elements/app_input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final AuthService _authService = AuthService();

  bool _notificationsEnabled = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) throw Exception("User not logged in");

      await _authService.changePassword(
        userId,
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully")),
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
            const Text("Change Password",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AppInputField(
              controller: _oldPasswordController,
              label: "Old Password",
              obscureText: true,
              validator: (value) =>
              value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _newPasswordController,
              label: "New Password",
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return "Field required";
                if (value.length < 6)
                  return "Password must be at least 6 characters long";
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _confirmPasswordController,
              label: "Confirm New Password",
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return "Field required";
                if (value != _newPasswordController.text)
                  return "Passwords do not match";
                return null;
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}

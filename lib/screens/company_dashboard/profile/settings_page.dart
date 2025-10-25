import 'package:flutter/material.dart';
import 'package:pot/l10n/app_localizations.dart';
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
      if (userId == null)
        throw Exception(
            AppLocalizations.of(context)!.translate('user_not_logged_in'));

      await _authService.changePassword(
        userId,
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('password_changed_successfully'))),
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.translate('error')}${e.toString()}')),
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
              title: Text(AppLocalizations.of(context)!
                  .translate('enable_notifications')),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 30),
            Text(AppLocalizations.of(context)!.translate('change_password'),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AppInputField(
              controller: _oldPasswordController,
              label: AppLocalizations.of(context)!.translate('old_password'),
              obscureText: true,
              validator: (value) => value == null || value.isEmpty
                  ? AppLocalizations.of(context)!.translate('field_required')
                  : null,
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _newPasswordController,
              label: AppLocalizations.of(context)!.translate('new_password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return AppLocalizations.of(context)!
                      .translate('field_required');
                if (value.length < 6)
                  return AppLocalizations.of(context)!
                      .translate('password_min_length');
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _confirmPasswordController,
              label: AppLocalizations.of(context)!
                  .translate('confirm_new_password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return AppLocalizations.of(context)!
                      .translate('field_required');
                if (value != _newPasswordController.text)
                  return AppLocalizations.of(context)!
                      .translate('passwords_do_not_match');
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
                  : Text(
                      AppLocalizations.of(context)!.translate('save_changes')),
            ),
          ],
        ),
      ),
    );
  }
}

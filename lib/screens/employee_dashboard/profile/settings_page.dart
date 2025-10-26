import 'package:flutter/material.dart';
import 'package:pot/l10n/app_localizations.dart';
import 'package:pot/services/auth_service.dart';
import 'package:pot/ui_elements/app_input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔹 Импортируем LanguageDropdown
import 'package:pot/ui_elements/language_dropdown.dart';

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
    final localizations = AppLocalizations.of(context);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception(localizations!.translate('user_not_logged_in'));
      }

      await _authService.changePassword(
        userId,
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(localizations!.translate('password_changed_successfully'))),
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${localizations!.translate('error')} ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // 🔹 Верхняя строка: "Settings" + LanguageDropdown справа
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations!.translate('language'),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const LanguageDropdown(),
              ],
            ),
            const SizedBox(height: 30),

            // 🔔 Переключатель уведомлений
            SwitchListTile(
              title: Text(localizations.translate('enable_notifications')),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 30),

            // 🔑 Секция изменения пароля
            Text(
              localizations.translate('change_password'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _oldPasswordController,
              label: localizations.translate('old_password'),
              obscureText: true,
              validator: (value) => value == null || value.isEmpty
                  ? localizations.translate('field_required')
                  : null,
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _newPasswordController,
              label: localizations.translate('new_password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.translate('field_required');
                }
                if (value.length < 6) {
                  return localizations.translate('password_min_length');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _confirmPasswordController,
              label: localizations.translate('confirm_new_password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.translate('field_required');
                }
                if (value != _newPasswordController.text) {
                  return localizations.translate('passwords_do_not_match');
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // 💾 Кнопка сохранения
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(localizations.translate('save_changes')),
            ),
          ],
        ),
      ),
    );
  }
}

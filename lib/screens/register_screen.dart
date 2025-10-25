import 'package:flutter/material.dart';
import 'package:pot/l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../ui_elements/app_input_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _promoCodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _isCompany = false;
  bool _isLoading = false;

  final auth = AuthService();

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isCompany) {
        await auth.register(
          _emailOrPhoneController.text,
          _passwordController.text,
          "company",
          name: _nameController.text,
        );
        Navigator.pushReplacementNamed(context, '/company');
      } else {
        final promoCode = _promoCodeController.text.trim();
        if (promoCode.isEmpty) {
          throw Exception("Promo code is required for employee");
        }

        final exists = await auth.promoCodeExists(promoCode);
        if (!exists) throw Exception("Invalid promo code");

        await auth.register(
          _emailOrPhoneController.text,
          _passwordController.text,
          "employee",
          promoCodeForEmployee: promoCode,
          name: _nameController.text,
        );
        Navigator.pushReplacementNamed(context, '/employee');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration success ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('new_account'),
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // переключатель employee/company
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_isCompany
                        ? AppLocalizations.of(context)!
                            .translate('register_as_company')
                        : AppLocalizations.of(context)!
                            .translate('register_as_employee')),
                    Switch(
                      value: _isCompany,
                      onChanged: (bool value) {
                        setState(() => _isCompany = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Full Name
                AppInputField(
                  controller: _nameController,
                  label: AppLocalizations.of(context)!.translate('full_name'),
                  hint: AppLocalizations.of(context)!
                      .translate('enter_your_name_and_surname'),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    final parts = value.trim().split(RegExp(r'\s+'));
                    if (parts.length < 2) {
                      return 'Please enter both name and surname';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email OR Phone
                AppInputField(
                  controller: _emailOrPhoneController,
                  label:
                      AppLocalizations.of(context)!.translate('email_or_phone'),
                  hint: AppLocalizations.of(context)!
                      .translate('enter_your_email_or_phone_number'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email or phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                AppInputField(
                  controller: _passwordController,
                  label: AppLocalizations.of(context)!.translate('password'),
                  hint: AppLocalizations.of(context)!
                      .translate('enter_your_password'),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),

                // Promo Code только для employee
                if (!_isCompany) ...[
                  AppInputField(
                    controller: _promoCodeController,
                    label:
                        AppLocalizations.of(context)!.translate('promo_code'),
                    hint: AppLocalizations.of(context)!
                        .translate('enter_your_promo_code'),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (!_isCompany &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Please enter your promo code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 20),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.translate('signup')),
                  ),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!
                        .translate('already_have_an_account')),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: Text(
                          AppLocalizations.of(context)!.translate('login'),
                          style: const TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

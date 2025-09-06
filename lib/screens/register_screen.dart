import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../ui_elements//app_input_field.dart'; // импортим твой общий инпут

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
        if (promoCode.isEmpty) throw Exception("Promo code is required for employee");

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
        title: const Text(
          "New Account",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
                    Text(_isCompany ? "Register as Company" : "Register as Employee"),
                    Switch(
                      value: _isCompany,
                      onChanged: (bool value) {
                        setState(() => _isCompany = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name
                AppInputField(
                  controller: _nameController,
                  label: "Full Name",
                  hint: "Enter your name",
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),

                // Email OR Phone
                AppInputField(
                  controller: _emailOrPhoneController,
                  label: "Email or Phone",
                  hint: "Enter your email or phone number",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password
                AppInputField(
                  controller: _passwordController,
                  label: "Password",
                  hint: "Enter your password",
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                    label: "Promo Code",
                    hint: "Enter your promo code",
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 20),

                // Кнопка Register
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
                        : const Text("Sign Up"),
                  ),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: const Text("Log in", style: TextStyle(color: Colors.blue)),
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

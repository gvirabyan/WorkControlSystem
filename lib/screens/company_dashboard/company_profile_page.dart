import 'package:flutter/material.dart';
import '../../services/company_profile_service.dart';

class CompanyProfilePage extends StatefulWidget {
  final String companyId; // передаём ID компании
  const CompanyProfilePage({super.key, required this.companyId});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedPlan = "Free";
  bool _isLoading = false;
  bool _isFetching = true; // данные ещё не загружены

  final _service = CompanyProfileService();

  @override
  void initState() {
    super.initState();
    _loadProfile();

  }

  Future<void> _loadProfile() async {

    final data = await _service.getCompanyProfile(widget.companyId);
    if (data != null) {
      _nameController.text = data['fullName'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _addressController.text = data['address'] ?? '';
      _selectedPlan = data['plan'] ?? 'Free';
    }
    setState(() => _isFetching = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await _service.saveCompanyProfile(
      companyId: widget.companyId,
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      plan: _selectedPlan,
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile saved ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.business,
                        size: 50, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 30),

                _buildTextFormField(
                  controller: _nameController,
                  hint: "Full Name",
                  keyboardType: TextInputType.name,
                  validator: (value) =>
                  value == null || value.isEmpty ? "Name required" : null,
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _emailController,
                  hint: "Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Email required";
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return "Invalid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _phoneController,
                  hint: "Phone",
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                  value == null || value.isEmpty ? "Phone required" : null,
                ),
                const SizedBox(height: 16),

                _buildTextFormField(
                  controller: _addressController,
                  hint: "Address",
                  keyboardType: TextInputType.streetAddress,
                  validator: (value) =>
                  value == null || value.isEmpty ? "Address required" : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedPlan,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Free", child: Text("Free")),
                    DropdownMenuItem(value: "Paid", child: Text("Paid")),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedPlan = value!);
                  },
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
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
                        : const Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../services/company_profile_service.dart';

class ProfilePage extends StatefulWidget {
  final String companyId; // передаём ID компании
  const ProfilePage({super.key, required this.companyId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Company information
  final _officialCompanyNameController = TextEditingController();
  final _registeredAddressController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _socialSecurityNumberController = TextEditingController();
  final _sectorOfActivityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();

  // Responsible persons
  final _managerFirstNameController = TextEditingController();
  final _managerLastNameController = TextEditingController();
  final _managerPositionController = TextEditingController();
  final _hrManagerFirstNameController = TextEditingController();
  final _hrManagerLastNameController = TextEditingController();
  final _technicalContactController = TextEditingController();

  bool _socialSecurityNumberNotApplicable = false;
  bool _websiteNotApplicable = false;

  bool _isLoading = false;
  bool _isFetching = true;

  final _service = CompanyProfileService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _officialCompanyNameController.dispose();
    _registeredAddressController.dispose();
    _registrationNumberController.dispose();
    _vatNumberController.dispose();
    _socialSecurityNumberController.dispose();
    _sectorOfActivityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _managerFirstNameController.dispose();
    _managerLastNameController.dispose();
    _managerPositionController.dispose();
    _hrManagerFirstNameController.dispose();
    _hrManagerLastNameController.dispose();
    _technicalContactController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final data = await _service.getCompanyProfile(widget.companyId);

    if (data != null) {
      _officialCompanyNameController.text = data['officialCompanyName'] ?? '';
      _registeredAddressController.text = data['registeredAddress'] ?? '';
      _registrationNumberController.text = data['registrationNumber'] ?? '';
      _vatNumberController.text = data['vatNumber'] ?? '';
      _socialSecurityNumberController.text = data['socialSecurityNumber'] ?? '';
      _sectorOfActivityController.text = data['sectorOfActivity'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _emailController.text = data['email'] ?? '';
      _websiteController.text = data['website'] ?? '';
      _managerFirstNameController.text = data['managerFirstName'] ?? '';
      _managerLastNameController.text = data['managerLastName'] ?? '';
      _managerPositionController.text = data['managerPosition'] ?? '';
      _hrManagerFirstNameController.text = data['hrManagerFirstName'] ?? '';
      _hrManagerLastNameController.text = data['hrManagerLastName'] ?? '';
      _technicalContactController.text = data['technicalContact'] ?? '';

      setState(() {
        _socialSecurityNumberNotApplicable = data['socialSecurityNumber'] == 'not applicable';
        _websiteNotApplicable = data['website'] == 'not applicable';
      });
    }

    setState(() => _isFetching = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await _service.saveCompanyProfile(
      companyId: widget.companyId,
      officialCompanyName: _officialCompanyNameController.text.trim(),
      registeredAddress: _registeredAddressController.text.trim(),
      registrationNumber: _registrationNumberController.text.trim(),
      vatNumber: _vatNumberController.text.trim(),
      socialSecurityNumber: _socialSecurityNumberNotApplicable ? 'not applicable' : _socialSecurityNumberController.text.trim(),
      sectorOfActivity: _sectorOfActivityController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      website: _websiteNotApplicable ? 'not applicable' : _websiteController.text.trim(),
      managerFirstName: _managerFirstNameController.text.trim(),
      managerLastName: _managerLastNameController.text.trim(),
      managerPosition: _managerPositionController.text.trim(),
      hrManagerFirstName: _hrManagerFirstNameController.text.trim(),
      hrManagerLastName: _hrManagerLastNameController.text.trim(),
      technicalContact: _technicalContactController.text.trim(),
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile saved ✅"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isFetching
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(child: _buildForm()),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text("Company Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _officialCompanyNameController,
              hint: "Official company name",
              keyboardType: TextInputType.name,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _registeredAddressController,
              hint: "Registered address",
              keyboardType: TextInputType.streetAddress,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _registrationNumberController,
              hint: "Registration number / RCS number",
              keyboardType: TextInputType.text,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _vatNumberController,
              hint: "VAT number",
              keyboardType: TextInputType.text,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _sectorOfActivityController,
              hint: "Sector of activity / NACE code",
              keyboardType: TextInputType.text,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _phoneController,
              hint: "Phone",
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _emailController,
              hint: "Email",
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return "Field required";
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return "Invalid email";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text("Social security number not applicable"),
              value: _socialSecurityNumberNotApplicable,
              onChanged: (value) {
                setState(() {
                  _socialSecurityNumberNotApplicable = value!;
                  if (_socialSecurityNumberNotApplicable) {
                    _socialSecurityNumberController.text = 'not applicable';
                  } else {
                    _socialSecurityNumberController.clear();
                  }
                });
              },
            ),
            _buildTextFormField(
              controller: _socialSecurityNumberController,
              hint: "Social security number",
              keyboardType: TextInputType.text,
              enabled: !_socialSecurityNumberNotApplicable,
              validator: (value) => !_socialSecurityNumberNotApplicable && (value == null || value.isEmpty) ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text("Website not applicable"),
              value: _websiteNotApplicable,
              onChanged: (value) {
                setState(() {
                  _websiteNotApplicable = value!;
                  if (_websiteNotApplicable) {
                    _websiteController.text = 'not applicable';
                  } else {
                    _websiteController.clear();
                  }
                });
              },
            ),
            _buildTextFormField(
              controller: _websiteController,
              hint: "Website",
              keyboardType: TextInputType.url,
              enabled: !_websiteNotApplicable,
              validator: (value) => !_websiteNotApplicable && (value == null || value.isEmpty) ? "Field required" : null,
            ),
            const SizedBox(height: 30),
            const Text("Responsible Persons", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _managerFirstNameController,
              hint: "Manager's first name",
              keyboardType: TextInputType.name,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _managerLastNameController,
              hint: "Manager's last name",
              keyboardType: TextInputType.name,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _managerPositionController,
              hint: "Manager's position",
              keyboardType: TextInputType.text,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _hrManagerFirstNameController,
              hint: "HR manager's first name",
              keyboardType: TextInputType.name,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _hrManagerLastNameController,
              hint: "HR manager's last name",
              keyboardType: TextInputType.name,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _technicalContactController,
              hint: "Technical contact person",
              keyboardType: TextInputType.text,
              validator: (value) => value == null || value.isEmpty ? "Field required" : null,
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
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      enabled: enabled,
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

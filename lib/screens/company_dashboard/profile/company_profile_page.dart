import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pot/l10n/app_localizations.dart';
import 'package:pot/ui_elements/app_input_field.dart';
import '../../../services/company_profile_service.dart';

class ProfilePage extends StatefulWidget {
  final String companyId;
  const ProfilePage({super.key, required this.companyId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Promo Code
  final _promoCodeController = TextEditingController();

  // Company information
  final _officialCompanyNameController = TextEditingController();
  final _commercialNameController = TextEditingController();
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

  File? _image;
  String? _avatarUrl;
  final _picker = ImagePicker();

  final _service = CompanyProfileService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    _officialCompanyNameController.dispose();
    _commercialNameController.dispose();
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isFetching = true);

    final data = await _service.getCompanyProfile(widget.companyId);

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.companyId)
        .get();

    if (userDoc.exists) {
      _promoCodeController.text = userDoc.data()?['promoCode'] ?? '';
    }

    if (data != null) {
      _officialCompanyNameController.text = data['officialCompanyName'] ?? '';
      _commercialNameController.text = data['commercialName'] ?? '';
      _registeredAddressController.text = data['registeredAddress'] ?? '';
      _registrationNumberController.text = data['registrationNumber'] ?? '';
      _vatNumberController.text = data['vatNumber'] ?? '';
      _socialSecurityNumberController.text =
          data['socialSecurityNumber'] ?? '';
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
        _socialSecurityNumberNotApplicable =
            data['socialSecurityNumber'] == 'not applicable';
        _websiteNotApplicable = data['website'] == 'not applicable';
        _avatarUrl = data['avatarUrl'];
      });
    }

    setState(() => _isFetching = false);
  }

  Future<void> _saveProfile() async {
    // ✅ Разрешаем сохранять даже одно поле (валидация отключена)
    // Только email проверяется, если он заполнен
    if (_emailController.text.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.translate('invalid_email_format')),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? avatarUrl = _avatarUrl;
    if (_image != null) {
      avatarUrl = await _service.uploadAvatar(widget.companyId, _image!);
    }

    await _service.saveCompanyProfile(
      companyId: widget.companyId,
      officialCompanyName: _officialCompanyNameController.text.trim(),
      commercialName: _commercialNameController.text.trim(),
      registeredAddress: _registeredAddressController.text.trim(),
      registrationNumber: _registrationNumberController.text.trim(),
      vatNumber: _vatNumberController.text.trim(),
      socialSecurityNumber: _socialSecurityNumberNotApplicable
          ? 'not applicable'
          : _socialSecurityNumberController.text.trim(),
      sectorOfActivity: _sectorOfActivityController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      website: _websiteNotApplicable
          ? 'not applicable'
          : _websiteController.text.trim(),
      managerFirstName: _managerFirstNameController.text.trim(),
      managerLastName: _managerLastNameController.text.trim(),
      managerPosition: _managerPositionController.text.trim(),
      hrManagerFirstName: _hrManagerFirstNameController.text.trim(),
      hrManagerLastName: _hrManagerLastNameController.text.trim(),
      technicalContact: _technicalContactController.text.trim(),
      avatarUrl: avatarUrl,
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.translate('profile_saved')),
        duration: const Duration(seconds: 2),
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
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : _avatarUrl != null
                            ? NetworkImage(_avatarUrl!)
                            : null,
                    child: _image == null && _avatarUrl == null
                        ? const Icon(Icons.business, size: 50)
                        : null,
                  ),
                  TextButton(
                    onPressed: _pickImage,
                    child: Text(
                        AppLocalizations.of(context)!.translate('change_avatar')),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.translate('company_information'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Promo code
            AppInputField(
              controller: _promoCodeController,
              label: AppLocalizations.of(context)!.translate('promo_code'),
              enabled: false,
            ),
            const SizedBox(height: 20),

            AppInputField(
              controller: _officialCompanyNameController,
              label: AppLocalizations.of(context)!
                  .translate('official_company_name'),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _commercialNameController,
              label:
                  AppLocalizations.of(context)!.translate('commercial_name'),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _registeredAddressController,
              label:
                  AppLocalizations.of(context)!.translate('registered_address'),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _registrationNumberController,
              label: AppLocalizations.of(context)!
                  .translate('registration_number_rcs_number'),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _vatNumberController,
              label: AppLocalizations.of(context)!.translate('vat_number'),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _sectorOfActivityController,
              label: AppLocalizations.of(context)!
                  .translate('sector_of_activity_nace_code'),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _phoneController,
              label: AppLocalizations.of(context)!.translate('phone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _emailController,
              label: AppLocalizations.of(context)!.translate('email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              title: Text(AppLocalizations.of(context)!
                  .translate('social_security_number_not_applicable')),
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
            AppInputField(
              controller: _socialSecurityNumberController,
              label: AppLocalizations.of(context)!
                  .translate('social_security_number'),
              enabled: !_socialSecurityNumberNotApplicable,
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              title: Text(AppLocalizations.of(context)!
                  .translate('website_not_applicable')),
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
            AppInputField(
              controller: _websiteController,
              label: AppLocalizations.of(context)!.translate('website'),
              keyboardType: TextInputType.url,
              enabled: !_websiteNotApplicable,
            ),
            const SizedBox(height: 30),

            Text(
              AppLocalizations.of(context)!.translate('responsible_persons'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _managerFirstNameController,
              label: AppLocalizations.of(context)!
                  .translate('managers_first_name'),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _managerLastNameController,
              label:
                  AppLocalizations.of(context)!.translate('managers_last_name'),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _managerPositionController,
              label:
                  AppLocalizations.of(context)!.translate('managers_position'),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _hrManagerFirstNameController,
              label: AppLocalizations.of(context)!
                  .translate('hr_managers_first_name'),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _hrManagerLastNameController,
              label: AppLocalizations.of(context)!
                  .translate('hr_managers_last_name'),
            ),
            const SizedBox(height: 16),
            AppInputField(
              controller: _technicalContactController,
              label: AppLocalizations.of(context)!
                  .translate('technical_contact_person'),
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
                    : Text(AppLocalizations.of(context)!.translate('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

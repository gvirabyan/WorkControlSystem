import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pot/l10n/app_localizations.dart';
import 'package:pot/screens/company_dashboard/profile/plans_page.dart';
import 'package:pot/screens/company_dashboard/profile/privacy_policy_page.dart';
import 'package:pot/screens/company_dashboard/profile/settings_page.dart';
import 'package:pot/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'company_profile_page.dart';
import 'help_page.dart';

class ProfileItems extends StatefulWidget {
  final String companyId;
  const ProfileItems({super.key, required this.companyId});

  @override
  State<ProfileItems> createState() => _ProfileItemsState();
}

class _ProfileItemsState extends State<ProfileItems> {
  Widget? _selectedPage;
  String? _selectedPageTitle;
  String? _companyName;
  String? _avatarUrl; // <-- URL аватара из Firestore
  bool _isUploading = false;

  late final List<Map<String, dynamic>> _menuItems;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _menuItems = [
      {
        'icon': Icons.person_outline,
        'title': AppLocalizations.of(context)!.translate('profile'),
        'page': ProfilePage(companyId: widget.companyId),
      },
      {
        'icon': Icons.lock_outline,
        'title': AppLocalizations.of(context)!.translate('privacy_policy'),
        'page': const PrivacyPolicyPage(),
      },
      {
        'icon': Icons.settings_outlined,
        'title': AppLocalizations.of(context)!.translate('settings'),
        'page': const SettingsPage(),
      },
      {
        'icon': Icons.add_chart_sharp,
        'title': AppLocalizations.of(context)!.translate('plans'),
        'page': const PlansPage(),
      },
      {
        'icon': Icons.help_outline,
        'title': AppLocalizations.of(context)!.translate('help'),
        'page': const HelpPage(),
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.companyId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _companyName = data['name'];
          _avatarUrl = data['avatarUrl']; // <-- Загружаем URL, если есть
        });
      }
    } catch (e) {
      debugPrint(
          "${AppLocalizations.of(context)!.translate('error_loading_company')}$e");
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars/${widget.companyId}.jpg');

      await storageRef.putFile(File(picked.path));
      final url = await storageRef.getDownloadURL();

      // Сохраняем URL в Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.companyId)
          .update({'avatarUrl': url});

      setState(() {
        _avatarUrl = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .translate('avatar_updated_successfully'))),
      );
    } catch (e) {
      debugPrint(
          "${AppLocalizations.of(context)!.translate('error_uploading_avatar')}$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.translate('error')}$e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        if (_selectedPage == null) ...[
          Column(
            children: [
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadAvatar,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: _avatarUrl != null
                          ? NetworkImage(_avatarUrl!)
                          : null,
                      child: _avatarUrl == null
                          ? const Icon(Icons.business,
                              size: 50, color: Colors.blue)
                          : null,
                    ),
                    if (_isUploading)
                      const CircularProgressIndicator(color: Colors.blue),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _companyName ??
                    AppLocalizations.of(context)!.translate('loading'),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
        Expanded(
          child: _selectedPage == null
              ? ListView(
                  children: [
                    ..._menuItems.map((item) => _buildMenuItem(
                          icon: item['icon'],
                          text: item['title'],
                          onTap: () =>
                              _openPage(item['page'], item['title']),
                        )),
                    const Divider(),
                    ListTile(
                      leading:
                          const Icon(Icons.logout, color: Colors.red, size: 28),
                      title: Text(
                        AppLocalizations.of(context)!.translate('logout'),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      onTap: _logout,
                    ),
                  ],
                )
              : _buildDetailPage(),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue, size: 28),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _openPage(Widget page, String title) {
    setState(() {
      _selectedPage = page;
      _selectedPageTitle = title;
    });
  }

  Widget _buildDetailPage() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_back, color: Colors.blue),
          title: Text(
            _selectedPageTitle ?? "",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onTap: () => setState(() {
            _selectedPage = null;
            _selectedPageTitle = null;
          }),
        ),
        const Divider(),
        Expanded(child: _selectedPage!),
      ],
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pot/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pot/ui_elements/task_card.dart';
import 'package:pot/models/task_model.dart' as model;

import '../all_tasks_page.dart';
import 'DailyReportPage.dart';
import 'VacationPage.dart';
import 'WeeklyHistoryPage.dart';

class EmployeeInfoPage extends StatefulWidget {
  final String userId;

  const EmployeeInfoPage({super.key, required this.userId});

  @override
  State<EmployeeInfoPage> createState() => _EmployeeInfoPageState();
}

class _EmployeeInfoPageState extends State<EmployeeInfoPage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDataFuture;
  final Map<String, TextEditingController> _controllers = {};

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadMessage;
  String? _contractUrl;

  @override
  void initState() {
    super.initState();
    _userDataFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get()
        .then((doc) {
      _contractUrl = doc.data()?['urlContract'];
      return doc;
    });
  }

  final _hiddenFields = ['type', 'createdAt', 'password', 'promoCode'];
  final _readonlyFields = [
    'name',
    'currentStatus',
    'emailOrPhone',
    'workedHours',
  ];

  final _personalFields = ['emailOrPhone', 'contact'];
  final _workFields = [
    'currentStatus',
    'position',
    'startDate',
    'endDate',
    'task',
    'workedHours',
    'weeklyHours',
    'workSchedule',
    'salary',
  ];

  Future<void> _saveChanges() async {
    final Map<String, dynamic> updatedData = {};

    _controllers.forEach((key, controller) {
      if (!_readonlyFields.contains(key)) {
        updatedData[key] =
            controller.text.isNotEmpty ? controller.text : (key == 'salary' ? '0' : '');
      }
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update(updatedData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('changes_saved_successfully'))),
    );
  }

  Future<void> _uploadContract() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) {
        setState(() {
          _isUploading = false;
          _uploadMessage =
              AppLocalizations.of(context)!.translate('upload_canceled');
        });
        return;
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _uploadMessage = null;
      });

      Uint8List fileBytes = result.files.single.bytes!;
      final fileName = '${widget.userId}_contract.pdf';
      final ref = FirebaseStorage.instance.ref().child('contracts/$fileName');

      final uploadTask = ref.putData(fileBytes);

      uploadTask.snapshotEvents.listen((taskSnapshot) {
        if (taskSnapshot.totalBytes > 0) {
          setState(() {
            _uploadProgress =
                taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
          });
        }
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'urlContract': url});

      setState(() {
        _contractUrl = url;
        _isUploading = false;
        _uploadProgress = 0.0;
        _uploadMessage =
            AppLocalizations.of(context)!.translate('upload_successful');
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
        _uploadMessage =
            '${AppLocalizations.of(context)!.translate('error')}$e';
      });
    }
  }

  Future<void> _previewContract() async {
    if (_contractUrl == null) return;
    final uri = Uri.parse(_contractUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('could_not_open_contract'))));
    }
  }

  Future<void> _downloadContract() async {
    if (_contractUrl == null) return;
    final uri = Uri.parse(_contractUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildField(
    String key,
    String value, {
    String? defaultValue,
    String? hintText,
  }) {
    final readOnly = _readonlyFields.contains(key);
    final controller = _controllers.putIfAbsent(
      key,
      () => TextEditingController(
        text: value.isNotEmpty ? value : (defaultValue ?? ''),
      ),
    );

    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType:
          key == 'salary' ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: key.replaceAll('_', ' ').toUpperCase(),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: hintText,
      ),
    );
  }

  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final statusController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final dueDateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('add_task')),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.translate('title')),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!
                        .translate('description')),
              ),
              TextField(
                controller: statusController,
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.translate('status')),
              ),
              TextField(
                controller: startDateController,
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.translate('start_date')),
              ),
              TextField(
                controller: endDateController,
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.translate('end_date')),
              ),
              TextField(
                controller: dueDateController,
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.translate('due_date')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final task = model.Task(
                id: '',
                title: titleController.text.isEmpty
                    ? '-'
                    : titleController.text,
                description: descriptionController.text.isEmpty
                    ? '-'
                    : descriptionController.text,
                status: statusController.text.isEmpty
                    ? '-'
                    : statusController.text,
                startDate: startDateController.text.isEmpty
                    ? '-'
                    : startDateController.text,
                endDate: endDateController.text.isEmpty
                    ? '-'
                    : endDateController.text,
                dueDate: dueDateController.text.isEmpty
                    ? '-'
                    : dueDateController.text,
              );

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection('tasks')
                  .add(task.toMap());

              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.translate('add')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)!.translate('employee_information')),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(
                child: Text(
                    AppLocalizations.of(context)!.translate('user_not_found')));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text(
                    AppLocalizations.of(context)!.translate('an_error_occurred')));
          }

          final userData = snapshot.data!.data()!;
          final name = userData['name'] ?? 'Unknown';
          final photoUrl = userData['photoUrl'] ??
              'https://ui-avatars.com/api/?name=$name&background=1976D2&color=fff';

          _hiddenFields.forEach(userData.remove);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(photoUrl),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ExpansionTile(
                  title: Text(
                    AppLocalizations.of(context)!
                        .translate('personal_information'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  initiallyExpanded: false, // по умолчанию свернуто
                  children: _personalFields
                      .where((f) => userData.containsKey(f))
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _buildField(f, userData[f].toString()),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 30),
                ExpansionTile(
                  title: Text(
                    AppLocalizations.of(context)!.translate('work_information'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  initiallyExpanded: false, // по умолчанию свернуто
                  children: _workFields.map((f) {
                    if (f == 'workSchedule') {
                      final scheduleText =
                          (userData[f]?.toString().isNotEmpty ?? false)
                              ? userData[f].toString()
                              : '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _buildField(
                          f,
                          scheduleText,
                          hintText: 'Mon-Fri 09:00-18:00',
                        ),
                      );
                    } else if (f == 'salary') {
                      final salaryText =
                          (userData[f]?.toString().isNotEmpty ?? false)
                              ? userData[f].toString()
                              : '0';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _buildField(f, salaryText),
                      );
                    } else if (userData.containsKey(f)) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _buildField(f, userData[f].toString()),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }).toList(),
                ),

                const SizedBox(height: 30),

                const SizedBox(height: 30),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),

                    // Tasks кнопка
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AllTasksPage(userId: widget.userId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.translate('tasks'),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // History кнопка
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WeeklyHistoryPage(userId: widget.userId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_month,
                            color: Colors.white),
                        label: Text(
                            AppLocalizations.of(context)!
                                .translate('history_of_last_week'),
                            style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Daily Report кнопка
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DailyReportPage(userId: widget.userId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_month,
                            color: Colors.white),
                        label: Text(
                            AppLocalizations.of(context)!
                                .translate('daily_report'),
                            style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Vacations кнопка
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  VacationPage(userId: widget.userId),
                            ),
                          );
                        },
                        icon:
                            const Icon(Icons.beach_access, color: Colors.white),
                        label: Text(
                            AppLocalizations.of(context)!.translate('vacations'),
                            style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),

                const SizedBox(height: 30),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('employment_contract'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: _isUploading
                      ? Column(
                          children: [
                            CircularProgressIndicator(
                              value:
                                  _uploadProgress > 0 ? _uploadProgress : null,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_uploadMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _uploadMessage!,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ],
                        )
                      : _contractUrl == null
                          ? ElevatedButton.icon(
                              onPressed: _uploadContract,
                              icon: const Icon(
                                Icons.upload_file,
                                color: Colors.white,
                              ),
                              label: Text(
                                AppLocalizations.of(context)!
                                    .translate('upload_contract'),
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _previewContract,
                                  icon: const Icon(
                                    Icons.visibility,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context)!
                                        .translate('preview_contract'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _downloadContract,
                                  icon: const Icon(
                                    Icons.download,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context)!
                                        .translate('download_contract'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                if (_uploadMessage != null) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    _uploadMessage!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context)!.translate('save_changes'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade500,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(AppLocalizations.of(context)!
                              .translate('confirm_action')),
                          content: Text(AppLocalizations.of(context)!.translate(
                              'are_you_sure_you_want_to_end_cooperation')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(AppLocalizations.of(context)!
                                  .translate('cancel')),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(AppLocalizations.of(context)!
                                  .translate('confirm')),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userId)
                              .update({'promoCode': null});

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .translate('cooperation_ended_successfully')),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${AppLocalizations.of(context)!.translate('error')}$e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.stop_circle, color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context)!
                          .translate('end_cooperation'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isWorking = false;
  bool _isOnBreak = false;
  Timer? _timer;
  int _totalSeconds = 0;

  final usersCollection = FirebaseFirestore.instance.collection('users');
  final historyCollection =
  FirebaseFirestore.instance.collection('employee_action_history');

  DocumentReference? _currentActionDoc;

  String _name = '';
  String _contact = '';
  String _promoCode = '';

  final TextEditingController _taskDescriptionController =
  TextEditingController();
  final TextEditingController _breakReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCurrentStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _taskDescriptionController.dispose();
    _breakReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final doc = await usersCollection.doc(widget.userId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    setState(() {
      _name = data['name'] ?? '';
      _contact = data['emailOrPhone'] ?? '';
      _promoCode = data['promoCode'] ?? '';
    });
  }

  Future<void> _loadCurrentStatus() async {
    final doc = await usersCollection.doc(widget.userId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final status = data['currentStatus'] ?? 'Not Working';

    final query = await historyCollection
        .where('userId', isEqualTo: widget.userId)
        .where('datetimeEnd', isEqualTo: null)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final currentAction = query.docs.first;
      _currentActionDoc = currentAction.reference;
      final desc = currentAction.data()['description'] ?? '';
      _taskDescriptionController.text = desc;
    }

    setState(() {
      _isWorking = status != 'Not Working';
      _isOnBreak = status == 'On Break';
    });

    // 🔹 Проверяем сохранённое время старта из SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final startTimeMillis = prefs.getInt('startTime');

    if (_isWorking && startTimeMillis != null) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
      final now = DateTime.now();
      final elapsedSeconds = now.difference(startTime).inSeconds;

      setState(() {
        _totalSeconds = elapsedSeconds > 0 ? elapsedSeconds : 0;
      });

      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _totalSeconds++;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _totalSeconds = 0;
    });
  }

  Future<void> _startAction(String action, {String? taskTitle}) async {
    if (_currentActionDoc != null) {
      await _currentActionDoc!
          .update({'datetimeEnd': FieldValue.serverTimestamp()});
    }

    final newDoc = await historyCollection.add({
      'userId': widget.userId,
      'name': _name,
      'contact': _contact,
      'action': action,
      'task': taskTitle ?? '',
      'promoCode': _promoCode,
      'description': _taskDescriptionController.text,
      'datetimeStart': FieldValue.serverTimestamp(),
      'datetimeEnd': null,
    });

    _currentActionDoc = newDoc;

    await usersCollection.doc(widget.userId).update({
      'currentStatus': action,
      if (taskTitle != null) 'task': taskTitle,
    });

    // 💾 Сохраняем/удаляем время старта
    final prefs = await SharedPreferences.getInstance();
    if (action == 'Working') {
      await prefs.setInt('startTime', DateTime.now().millisecondsSinceEpoch);
    } else {
      await prefs.remove('startTime');
    }
  }

  Future<void> _endAction() async {
    if (_currentActionDoc != null) {
      await _currentActionDoc!
          .update({'datetimeEnd': FieldValue.serverTimestamp()});
      _currentActionDoc = null;
    }
    await usersCollection.doc(widget.userId).update({
      'currentStatus': 'Not Working',
      'task': null,
    });

    // ❌ Удаляем сохранённое время старта
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('startTime');
  }

  Future<void> _saveTaskDescription() async {
    if (_currentActionDoc != null) {
      await _currentActionDoc!.update({
        'description': _taskDescriptionController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!
              .translate('description_saved'))));
    }
  }

  Future<void> _showTaskSelectionDialog() async {
    String? selectedTask;
    final localizations = AppLocalizations.of(context)!;

    final snapshot =
        await usersCollection.doc(widget.userId).collection('tasks').get();

    final taskTitles =
        snapshot.docs.map((doc) => doc['title'] as String).toList();

    if (taskTitles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(localizations.translate('no_tasks_available'))),
      );
      return;
    }

    await showDialog<String>(
      context: context,
      builder: (context) {
        String? tempSelectedTask = selectedTask;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(localizations.translate('select_task')),
              content: DropdownButton<String>(
                isExpanded: true,
                value: tempSelectedTask,
                hint: Text(localizations.translate('choose_a_task')),
                items: taskTitles.map((title) {
                  return DropdownMenuItem(
                    value: title,
                    child: Text(title),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    tempSelectedTask = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(localizations.translate('cancel')),
                ),
                ElevatedButton(
                  onPressed: tempSelectedTask == null
                      ? null
                      : () {
                          Navigator.pop(context, tempSelectedTask);
                        },
                  child: Text(localizations.translate('ok')),
                ),
              ],
            );
          },
        );
      },
    ).then((value) async {
      if (value != null) {
        _taskDescriptionController.clear();
        _startTimer();
        await _startAction('Working', taskTitle: value);
        setState(() {
          _isWorking = true;
          _isOnBreak = false;
        });
      }
    });
  }

  void _toggleWorkState() async {
    if (_isWorking) {
      _pauseTimer();
      _resetTimer();
      await _endAction();
      setState(() {
        _isWorking = false;
        _isOnBreak = false;
        _taskDescriptionController.clear();
      });
    } else {
      await _showTaskSelectionDialog();
    }
  }

  void _toggleBreakState() async {
    if (_isOnBreak) {
      _startTimer();
      await _startAction('Working');
      setState(() {
        _isOnBreak = false;
      });
    } else {
      await _takeBreak();
    }
  }

  Future<void> _takeBreak() async {
    final localizations = AppLocalizations.of(context)!;
    String? reason = await showDialog<String>(
      context: context,
      builder: (context) {
        _breakReasonController.clear();
        return AlertDialog(
          title: Text(localizations.translate('break_reason')),
          content: TextField(
            controller: _breakReasonController,
            decoration: InputDecoration(
                hintText: localizations.translate('enter_reason_for_break')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (_breakReasonController.text.isEmpty) return;
                Navigator.pop(context, _breakReasonController.text);
              },
              child: Text(localizations.translate('save')),
            ),
          ],
        );
      },
    );

    if (reason != null && reason.isNotEmpty) {
      if (_currentActionDoc != null) {
        await _currentActionDoc!.update({
          'breakReason': reason,
        });
      }
      _pauseTimer();
      await _startAction('On Break');
      setState(() {
        _isOnBreak = true;
      });
    }
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isWorking
                  ? (_isOnBreak
                      ? localizations.translate('on_break')
                      : localizations.translate('currently_working'))
                  : localizations.translate('not_working'),
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_isWorking)
              Text(
                _formatTime(_totalSeconds),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            const SizedBox(height: 20),
            if (_isWorking)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                      controller: _taskDescriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: localizations
                            .translate('task_description_notes'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _saveTaskDescription,
                      child: Text(
                          localizations.translate('save_description')),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            if (!_isWorking)
              ElevatedButton(
                onPressed: _toggleWorkState,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(localizations.translate('start_work')),
              )
            else if (_isWorking && !_isOnBreak)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _toggleWorkState,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: Text(localizations.translate('finish_work')),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _toggleBreakState,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: Text(localizations.translate('break')),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: _toggleBreakState,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(localizations.translate('continue_work')),
              ),
          ],
        ),
      ),
    );
  }
}

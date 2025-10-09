import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final historyCollection = FirebaseFirestore.instance.collection('employee_action_history');

  DocumentReference? _currentActionDoc;

  String _name = '';
  String _contact = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCurrentStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final doc = await usersCollection.doc(widget.userId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    setState(() {
      _name = data['name'] ?? '';
      _contact = data['emailOrPhone'] ?? '';
    });
  }

  Future<void> _loadCurrentStatus() async {
    final doc = await usersCollection.doc(widget.userId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final status = data['currentStatus'] ?? 'Not Working';
    setState(() {
      _isWorking = status != 'Not Working';
      _isOnBreak = status == 'On Break';
    });

    if (_isWorking && !_isOnBreak) {
      _startTimer();
    }

    // Проверяем наличие незавершённого действия
    final query = await historyCollection
        .where('userId', isEqualTo: widget.userId)
        .where('datetimeEnd', isEqualTo: null)
        .get();

    if (query.docs.isNotEmpty) {
      _currentActionDoc = query.docs.first.reference;
    }
  }

  void _startTimer() {
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

  Future<void> _startAction(String action) async {
    // Завершаем текущее действие
    if (_currentActionDoc != null) {
      await _currentActionDoc!.update({
        'datetimeEnd': FieldValue.serverTimestamp(),
      });
    }

    // Создаём новую запись в истории
    final newDoc = await historyCollection.add({
      'userId': widget.userId,
      'name': _name,
      'contact': _contact,
      'action': action,
      'datetimeStart': FieldValue.serverTimestamp(),
      'datetimeEnd': null,
    });

    _currentActionDoc = newDoc;

    // Обновляем статус в users
    await usersCollection.doc(widget.userId).update({'currentStatus': action});
  }

  Future<void> _endAction() async {
    if (_currentActionDoc != null) {
      await _currentActionDoc!.update({
        'datetimeEnd': FieldValue.serverTimestamp(),
      });
      _currentActionDoc = null;
    }
    await usersCollection.doc(widget.userId).update({'currentStatus': 'Not Working'});
  }

  void _toggleWorkState() async {
    if (_isWorking) {
      _pauseTimer();
      _resetTimer();
      await _endAction();
      setState(() {
        _isWorking = false;
        _isOnBreak = false;
      });
    } else {
      _startTimer();
      await _startAction('Working');
      setState(() {
        _isWorking = true;
        _isOnBreak = false;
      });
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
    return '${hours.toString().padLeft(2,'0')}:${minutes.toString().padLeft(2,'0')}:${seconds.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isWorking ? (_isOnBreak ? 'On Break' : 'Currently Working') : 'Not Working',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (_isWorking)
            Text(
              _formatTime(_totalSeconds),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          const SizedBox(height: 30),
          if (!_isWorking)
            ElevatedButton(
              onPressed: _toggleWorkState,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Start Work'),
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
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Finish Work'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _toggleBreakState,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Break'),
                ),
              ],
            )
          else
            ElevatedButton(
              onPressed: _toggleBreakState,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Continue Work'),
            ),
        ],
      ),
    );
  }
}

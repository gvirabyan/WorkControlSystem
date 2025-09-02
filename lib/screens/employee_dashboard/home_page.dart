import 'package:flutter/material.dart';
import 'dart:async'; // Импортируем для работы с таймером

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Переменная для отслеживания состояния работы
  bool _isWorking = false;
  // Переменная для отслеживания состояния перерыва
  bool _isOnBreak = false;
  // Таймер для отслеживания времени
  Timer? _timer;
  // Общее количество секунд
  int _totalSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  void _toggleWorkState() {
    if (_isWorking) {
      // Если работаем, то завершаем работу
      _pauseTimer();
      _resetTimer();
    } else {
      // Если не работаем, то начинаем
      _startTimer();
    }

    setState(() {
      _isWorking = !_isWorking;
      _isOnBreak = false; // Сброс состояния перерыва
    });
  }

  void _toggleBreakState() {
    setState(() {
      _isOnBreak = !_isOnBreak;
    });

    if (_isOnBreak) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isWorking
                ? (_isOnBreak ? 'On Break' : 'Currently Working')
                : 'Not Working',
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
          // Кнопка "Start Work", если не работаем
            ElevatedButton(
              onPressed: _toggleWorkState,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Start Work'),
            )
          else if (_isWorking && !_isOnBreak)
          // Кнопки "Finish Work" и "Break", если работаем
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
                  child: const Text('Finish Work'),
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
                  child: const Text('Break'),
                ),
              ],
            )
          else
          // Кнопка "Continue Work", если на перерыве
            ElevatedButton(
              onPressed: _toggleBreakState,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Continue Work'),
            ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/study_session.dart';

class TimerProvider with ChangeNotifier {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  // Lista de matérias começa vazia
  final List<String> _subjects = [];
  String? _selectedSubject;
  final List<StudySession> _sessions = [];

  int get seconds => _seconds;
  bool get isRunning => _isRunning;
  String? get selectedSubject => _selectedSubject;
  List<String> get subjects => _subjects;
  List<StudySession> get sessions => List.unmodifiable(_sessions);

  String get formattedTime {
    final hours = (_seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  void setSubject(String newSubject) {
    _selectedSubject = newSubject;
    notifyListeners();
  }

  void addSubject(String newSubject) {
    final trimmed = newSubject.trim();
    if (trimmed.isNotEmpty && !_subjects.contains(trimmed)) {
      _subjects.add(trimmed);
      _selectedSubject = trimmed; // Seleciona automaticamente a nova matéria criada
      notifyListeners();
    }
  }

  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    pauseTimer();
    if (_seconds > 0 && _selectedSubject != null) {
      _sessions.add(StudySession(
        subject: _selectedSubject!,
        duration: Duration(seconds: _seconds),
        date: DateTime.now(),
      ));
    }
    _seconds = 0;
    notifyListeners();
  }

  Duration get todayTotalTime {
    final now = DateTime.now();
    return _sessions
        .where((s) => s.date.year == now.year && s.date.month == now.month && s.date.day == now.day)
        .fold(Duration.zero, (prev, s) => prev + s.duration);
  }

  Duration get weekTotalTime {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _sessions
        .where((s) => s.date.isAfter(startOfWeek.subtract(const Duration(days: 1))))
        .fold(Duration.zero, (prev, s) => prev + s.duration);
  }

  String get mostStudiedSubject {
    if (_sessions.isEmpty) return 'Nenhuma';
    final Map<String, Duration> totals = {};
    for (var session in _sessions) {
      totals[session.subject] = (totals[session.subject] ?? Duration.zero) + session.duration;
    }
    return totals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
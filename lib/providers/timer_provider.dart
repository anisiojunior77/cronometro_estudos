import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_session.dart';

class TimerProvider with ChangeNotifier {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  List<String> _subjects = [];
  String? _selectedSubject;
  List<StudySession> _sessions = [];

  TimerProvider() {
    _loadData();
  }

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

  // --- PERSISTÊNCIA DE DADOS ---

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _subjects = prefs.getStringList('saved_subjects') ?? [];

    final String? sessionsJson = prefs.getString('saved_sessions');
    if (sessionsJson != null) {
      final List<dynamic> decoded = json.decode(sessionsJson);
      _sessions = decoded.map((item) => StudySession.fromMap(item)).toList();
    }

    if (_subjects.isNotEmpty) {
      _selectedSubject = _subjects.first;
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_subjects', _subjects);

    final List<Map<String, dynamic>> sessionsMap =
    _sessions.map((s) => s.toMap()).toList();
    await prefs.setString('saved_sessions', json.encode(sessionsMap));
  }

  // --- REMOÇÃO DO HISTÓRICO E MATÉRIAS ---

  void deleteSession(int index) {
    if (index >= 0 && index < _sessions.length) {
      _sessions.removeAt(index);
      _saveData();
      notifyListeners();
    }
  }

  void clearAllSessions() {
    _sessions.clear();
    _saveData();
    notifyListeners();
  }

  void deleteSubject(String subjectName) {
    _subjects.remove(subjectName);
    if (_selectedSubject == subjectName) {
      _selectedSubject = _subjects.isNotEmpty ? _subjects.first : null;
    }
    _saveData();
    notifyListeners();
  }

  // --- LÓGICA DO CRONÔMETRO ---

  void setSubject(String newSubject) {
    _selectedSubject = newSubject;
    notifyListeners();
  }

  void addSubject(String newSubject) {
    final trimmed = newSubject.trim();
    if (trimmed.isNotEmpty && !_subjects.contains(trimmed)) {
      _subjects.add(trimmed);
      _selectedSubject = trimmed;
      _saveData();
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
      _saveData();
    }
    _seconds = 0;
    notifyListeners();
  }

  Duration get todayTotalTime {
    final now = DateTime.now();
    return _sessions
        .where((s) =>
    s.date.year == now.year &&
        s.date.month == now.month &&
        s.date.day == now.day)
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
      totals[session.subject] =
          (totals[session.subject] ?? Duration.zero) + session.duration;
    }
    return totals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
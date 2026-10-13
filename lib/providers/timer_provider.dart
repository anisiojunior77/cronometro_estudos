import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_session.dart';

class TimerProvider with ChangeNotifier {
  // O tempo NÃO é contado somando +1 a cada tick (isso para quando o app vai
  // para segundo plano). Em vez disso guardamos o horário de início e
  // calculamos o tempo decorrido a partir dele.
  Timer? _ticker;
  Duration _accumulated = Duration.zero; // tempo de trechos já pausados
  DateTime? _startedAt; // início do trecho atual (null = pausado)
  int _lastShownSeconds = -1;

  List<String> _subjects = [];
  String? _selectedSubject;
  List<StudySession> _sessions = [];

  TimerProvider() {
    _loadData();
  }

  bool get isRunning => _startedAt != null;

  Duration get elapsed {
    final startedAt = _startedAt;
    if (startedAt == null) return _accumulated;
    final running = DateTime.now().difference(startedAt);
    return _accumulated + (running.isNegative ? Duration.zero : running);
  }

  int get seconds => elapsed.inSeconds;
  String? get selectedSubject => _selectedSubject;
  List<String> get subjects => List.unmodifiable(_subjects);
  List<StudySession> get sessions => List.unmodifiable(_sessions);

  String get formattedTime {
    final total = seconds;
    final hours = (total ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((total % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (total % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // --- PERSISTÊNCIA DE DADOS ---

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _subjects = List<String>.of(prefs.getStringList('saved_subjects') ?? []);

      final String? sessionsJson = prefs.getString('saved_sessions');
      if (sessionsJson != null) {
        final decoded = json.decode(sessionsJson);
        if (decoded is List) {
          for (final item in decoded) {
            try {
              _sessions.add(
                StudySession.fromMap(Map<String, dynamic>.from(item as Map)),
              );
            } catch (e) {
              // Ignora só o registro estragado e mantém os demais.
              debugPrint('Sessão inválida ignorada: $e');
            }
          }
        }
      }

      final savedSubject = prefs.getString('selected_subject');
      if (savedSubject != null && _subjects.contains(savedSubject)) {
        _selectedSubject = savedSubject;
      } else if (_subjects.isNotEmpty) {
        _selectedSubject = _subjects.first;
      }

      // Restaura um cronômetro que estava em andamento (ex.: app fechado).
      _accumulated = Duration(milliseconds: prefs.getInt('timer_accumulated') ?? 0);
      final startedRaw = prefs.getString('timer_started_at');
      final started = startedRaw == null ? null : DateTime.tryParse(startedRaw);
      if (started != null) {
        _startedAt = started;
        _startTicker();
      }
    } catch (e) {
      // Dados corrompidos não devem derrubar o app na abertura.
      debugPrint('Erro ao carregar dados salvos: $e');
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

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timer_accumulated', _accumulated.inMilliseconds);

    final startedAt = _startedAt;
    if (startedAt != null) {
      await prefs.setString('timer_started_at', startedAt.toIso8601String());
    } else {
      await prefs.remove('timer_started_at');
    }

    final subject = _selectedSubject;
    if (subject != null) {
      await prefs.setString('selected_subject', subject);
    } else {
      await prefs.remove('selected_subject');
    }
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
    _saveTimerState();
    notifyListeners();
  }

  // --- LÓGICA DO CRONÔMETRO ---

  void setSubject(String newSubject) {
    _selectedSubject = newSubject;
    _saveTimerState();
    notifyListeners();
  }

  void addSubject(String newSubject) {
    final trimmed = newSubject.trim();
    if (trimmed.isNotEmpty && !_subjects.contains(trimmed)) {
      _subjects.add(trimmed);
      _selectedSubject = trimmed;
      _saveData();
      _saveTimerState();
      notifyListeners();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _lastShownSeconds = seconds;
    // Roda várias vezes por segundo só para atualizar a tela no momento certo;
    // o valor em si vem sempre do horário de início, então não "perde" tempo.
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final current = seconds;
      if (current != _lastShownSeconds) {
        _lastShownSeconds = current;
        notifyListeners();
      }
    });
  }

  void startTimer() {
    if (isRunning) return;
    _startedAt = DateTime.now();
    _startTicker();
    _saveTimerState();
    notifyListeners();
  }

  void pauseTimer() {
    if (!isRunning) return;
    _accumulated = elapsed;
    _startedAt = null;
    _ticker?.cancel();
    _saveTimerState();
    notifyListeners();
  }

  void _resetTimerState() {
    _ticker?.cancel();
    _accumulated = Duration.zero;
    _startedAt = null;
    _lastShownSeconds = -1;
    _saveTimerState();
    notifyListeners();
  }

  /// Pausa, grava a sessão no histórico e zera o cronômetro.
  /// Retorna false (sem zerar nada) se não há matéria selecionada ou tempo.
  bool saveSession() {
    final subject = _selectedSubject;
    pauseTimer();
    if (subject == null || _accumulated.inSeconds == 0) return false;

    _sessions.add(StudySession(
      subject: subject,
      duration: Duration(seconds: _accumulated.inSeconds),
      date: DateTime.now(),
    ));
    _saveData();
    _resetTimerState();
    return true;
  }

  /// Zera o cronômetro sem gravar nada no histórico.
  void discardSession() {
    pauseTimer();
    _resetTimerState();
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
    // Segunda-feira desta semana, à meia-noite.
    final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    return _sessions
        .where((s) => !s.date.isBefore(startOfWeek))
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

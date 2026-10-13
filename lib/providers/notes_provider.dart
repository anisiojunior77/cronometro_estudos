import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NotesProvider with ChangeNotifier {
  final List<Note> _notes = [];

  NotesProvider() {
    _loadNotes();
  }

  /// Notas de uma matéria (ou todas, se subject for null), mais recentes primeiro.
  List<Note> notesFor(String? subject) {
    final list = subject == null
        ? List<Note>.of(_notes)
        : _notes.where((n) => n.subject == subject).toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('saved_notes');
      if (raw != null) {
        final decoded = json.decode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            try {
              _notes.add(Note.fromMap(Map<String, dynamic>.from(item as Map)));
            } catch (e) {
              debugPrint('Nota inválida ignorada: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar notas: $e');
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'saved_notes',
      json.encode(_notes.map((n) => n.toMap()).toList()),
    );
  }

  /// Cria uma nota nova (existing == null) ou atualiza uma existente.
  /// Nota completamente vazia não é salva (e uma existente que ficou vazia é apagada).
  void saveNote({
    Note? existing,
    required String title,
    required String content,
    String? subject,
  }) {
    final cleanTitle = title.trim();
    final cleanContent = content.trimRight();
    final isEmpty = cleanTitle.isEmpty && cleanContent.trim().isEmpty;

    if (existing == null) {
      if (isEmpty) return;
      _notes.add(Note(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: cleanTitle,
        content: cleanContent,
        subject: subject,
        updatedAt: DateTime.now(),
      ));
    } else {
      final index = _notes.indexWhere((n) => n.id == existing.id);
      if (index == -1) return;

      if (isEmpty) {
        _notes.removeAt(index);
      } else {
        final unchanged = existing.title == cleanTitle &&
            existing.content == cleanContent &&
            existing.subject == subject;
        if (unchanged) return; // não mexe na data se nada mudou
        _notes[index] = Note(
          id: existing.id,
          title: cleanTitle,
          content: cleanContent,
          subject: subject,
          updatedAt: DateTime.now(),
        );
      }
    }

    _persist();
    notifyListeners();
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    _persist();
    notifyListeners();
  }
}
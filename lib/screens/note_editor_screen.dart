import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/timer_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note; // null = nota nova
  final String? initialSubject;

  const NoteEditorScreen({super.key, this.note, this.initialSubject});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String? _subject;
  bool _deleted = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _subject = widget.note?.subject ?? widget.initialSubject;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    if (_deleted) return;
    context.read<NotesProvider>().saveNote(
      existing: widget.note,
      title: _titleController.text,
      content: _contentController.text,
      subject: _subject,
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Apagar nota'),
          content: const Text('Tem certeza de que deseja apagar esta nota?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Apagar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      _deleted = true; // impede o salvamento automático ao voltar
      context.read<NotesProvider>().deleteNote(widget.note!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<TimerProvider>().subjects;
    // Se a matéria da nota foi apagada, ela ainda precisa existir na lista.
    final options = <String>{...subjects, if (_subject != null) _subject!}.toList();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _save();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? 'Nova nota' : 'Editar nota'),
          actions: [
            if (widget.note != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Apagar nota',
                onPressed: _confirmDelete,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _subject,
                decoration: const InputDecoration(
                  labelText: 'Matéria',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Sem matéria'),
                  ),
                  for (final s in options)
                    DropdownMenuItem<String>(value: s, child: Text(s)),
                ],
                onChanged: (value) => setState(() => _subject = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                autofocus: widget.note == null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Título',
                  border: InputBorder.none,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Escreva sua nota...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
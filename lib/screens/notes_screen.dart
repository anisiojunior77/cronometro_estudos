import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../providers/timer_provider.dart';
import 'note_editor_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String? _filterSubject; // null = todas as matérias

  void _openEditor({Note? note, String? filter}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          note: note,
          initialSubject: filter ?? context.read<TimerProvider>().selectedSubject,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<TimerProvider>().subjects;
    final notesProvider = context.watch<NotesProvider>();

    // Se a matéria filtrada foi apagada, volta para "Todas".
    final filter = subjects.contains(_filterSubject) ? _filterSubject : null;
    final notes = notesProvider.notesFor(filter);

    return Scaffold(
      appBar: AppBar(title: const Text('Notas'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova nota',
        onPressed: () => _openEditor(filter: filter),
        child: const Icon(Icons.edit),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Todas'),
                    selected: filter == null,
                    onSelected: (_) => setState(() => _filterSubject = null),
                  ),
                ),
                for (final subject in subjects)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(subject),
                      selected: filter == subject,
                      onSelected: (_) => setState(() => _filterSubject = subject),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? const Center(
              child: Text(
                'Nenhuma nota ainda.\nToque no lápis para criar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final preview = note.content.replaceAll('\n', ' ');
                final date = DateFormat('dd/MM HH:mm').format(note.updatedAt);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    isThreeLine: true,
                    onTap: () => _openEditor(note: note),
                    title: Text(
                      note.title.isEmpty ? 'Sem título' : note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preview.isEmpty ? 'Sem texto adicional' : preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${note.subject ?? 'Sem matéria'} · $date',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
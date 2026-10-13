import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  void _showAddSubjectDialog(BuildContext context, TimerProvider provider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Matéria'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nome da Matéria',
              hintText: 'Ex: Biologia, Espanhol...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  provider.addSubject(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSubject(BuildContext context, TimerProvider provider, String subject) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Matéria'),
          content: Text('Tem certeza de que deseja remover "$subject" da lista?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                provider.deleteSubject(subject);
                Navigator.pop(context);
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cronômetro de Estudos'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: timerProvider.selectedSubject,
                    hint: const Text('Adicione uma matéria no botão +'),
                    decoration: const InputDecoration(
                      labelText: 'Matéria',
                      border: OutlineInputBorder(),
                    ),
                    items: timerProvider.subjects.map((subject) {
                      return DropdownMenuItem(value: subject, child: Text(subject));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) timerProvider.setSubject(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Botão Cinza para Apagar Matéria
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.grey.shade300,
                  ),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Apagar Matéria Selecionada',
                  onPressed: timerProvider.selectedSubject == null
                      ? null
                      : () => _confirmDeleteSubject(
                      context, timerProvider, timerProvider.selectedSubject!),
                ),
                const SizedBox(width: 8),
                // Botão de Adicionar Matéria
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  tooltip: 'Adicionar Matéria',
                  onPressed: () => _showAddSubjectDialog(context, timerProvider),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              timerProvider.formattedTime,
              style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.large(
                  onPressed: timerProvider.isRunning
                      ? timerProvider.pauseTimer
                      : timerProvider.startTimer,
                  child: Icon(timerProvider.isRunning ? Icons.pause : Icons.play_arrow),
                ),
                FloatingActionButton.large(
                  backgroundColor: Colors.redAccent,
                  onPressed: timerProvider.resetTimer,
                  child: const Icon(Icons.stop),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
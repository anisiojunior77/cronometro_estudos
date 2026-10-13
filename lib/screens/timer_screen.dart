import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../utils/format.dart';

enum _StopAction { cancel, discard, save }

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

  Future<void> _onStopPressed(BuildContext context, TimerProvider provider) async {
    if (provider.seconds == 0) return;

    final subject = provider.selectedSubject;
    if (subject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha uma matéria antes de finalizar a sessão.'),
        ),
      );
      return;
    }

    // Pausa enquanto o usuário decide, para o tempo não continuar correndo.
    final wasRunning = provider.isRunning;
    provider.pauseTimer();

    final action = await showDialog<_StopAction>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Finalizar sessão?'),
          content: Text(
            'Matéria: $subject\n'
            'Tempo: ${formatDuration(Duration(seconds: provider.seconds), showSeconds: true)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, _StopAction.cancel),
              child: const Text('Voltar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, _StopAction.discard),
              child: const Text(
                'Descartar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, _StopAction.save),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    switch (action) {
      case _StopAction.save:
        provider.saveSession();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sessão salva no histórico.')),
          );
        }
        break;
      case _StopAction.discard:
        provider.discardSession();
        break;
      case _StopAction.cancel:
      case null:
        // Tocou fora do diálogo ou em "Voltar": retoma de onde parou.
        if (wasRunning) provider.startTimer();
        break;
    }
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
                    // A key nova força o campo a se atualizar quando a matéria
                    // selecionada ou a lista mudam (initialValue só vale na 1ª vez).
                    key: ValueKey(
                      '${timerProvider.selectedSubject}|${timerProvider.subjects.length}',
                    ),
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
              style: const TextStyle(
                fontSize: 54,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.large(
                  heroTag: 'play_pause',
                  tooltip: timerProvider.isRunning ? 'Pausar' : 'Iniciar',
                  onPressed: timerProvider.isRunning
                      ? timerProvider.pauseTimer
                      : timerProvider.startTimer,
                  child: Icon(timerProvider.isRunning ? Icons.pause : Icons.play_arrow),
                ),
                FloatingActionButton.large(
                  heroTag: 'stop',
                  tooltip: 'Finalizar sessão',
                  backgroundColor: Colors.redAccent,
                  onPressed: () => _onStopPressed(context, timerProvider),
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

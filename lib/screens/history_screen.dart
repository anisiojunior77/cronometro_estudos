import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/timer_provider.dart';
import '../utils/format.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _confirmClearAll(BuildContext context, TimerProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpar Histórico'),
          content: const Text('Tem certeza de que deseja apagar todo o histórico de estudos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                provider.clearAllSessions();
                Navigator.pop(context);
              },
              child: const Text('Apagar Tudo', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final sessions = timerProvider.sessions.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Estudos'),
        centerTitle: true,
        actions: [
          if (sessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              tooltip: 'Limpar Todo o Histórico',
              onPressed: () => _confirmClearAll(context, timerProvider),
            ),
        ],
      ),
      body: sessions.isEmpty
          ? const Center(
        child: Text(
          'Nenhuma sessão registrada ainda.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          // Como invertemos a lista para mostrar os mais recentes primeiro,
          // calculamos o índice original correspondente:
          final originalIndex = timerProvider.sessions.length - 1 - index;
          final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(session.date);
          final durationText = formatDuration(session.duration, showSeconds: true);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.deepPurpleAccent),
              title: Text(
                session.subject,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(formattedDate),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    durationText,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Apagar Registro',
                    onPressed: () => timerProvider.deleteSession(originalIndex),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
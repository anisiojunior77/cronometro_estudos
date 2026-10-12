import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Sessões'), centerTitle: true),
      body: timerProvider.sessions.isEmpty
          ? const Center(child: Text('Nenhuma sessão registrada ainda.'))
          : ListView.builder(
        itemCount: timerProvider.sessions.length,
        itemBuilder: (context, index) {
          final session = timerProvider.sessions.reversed.toList()[index];
          final dateFormatted = DateFormat('dd/MM/yyyy - HH:mm').format(session.date);

          return ListTile(
            leading: const Icon(Icons.book),
            title: Text(session.subject),
            subtitle: Text(dateFormatted),
            trailing: Text(
              '${session.duration.inMinutes}m ${session.duration.inSeconds % 60}s',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../utils/format.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Tempo Estudado Hoje'),
                subtitle: Text(formatDuration(timerProvider.todayTotalTime)),
                leading: const Icon(Icons.today),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Total da Semana'),
                subtitle: Text(formatDuration(timerProvider.weekTotalTime)),
                leading: const Icon(Icons.date_range),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Matéria Mais Estudada'),
                subtitle: Text(timerProvider.mostStudiedSubject),
                leading: const Icon(Icons.star),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

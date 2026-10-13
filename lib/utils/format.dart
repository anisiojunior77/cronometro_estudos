/// Formata uma duração de forma legível:
/// 2h 05min  |  45min 10s (com segundos)  |  45min  |  30s (com segundos)
String formatDuration(Duration d, {bool showSeconds = false}) {
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  final seconds = d.inSeconds % 60;

  if (hours > 0) {
    return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
  }
  if (minutes > 0) {
    return showSeconds && seconds > 0 ? '${minutes}min ${seconds}s' : '${minutes}min';
  }
  return showSeconds ? '${seconds}s' : '${minutes}min';
}

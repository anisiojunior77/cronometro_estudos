import 'dart:convert';

class StudySession {
  final String subject;
  final Duration duration;
  final DateTime date;

  StudySession({
    required this.subject,
    required this.duration,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'duration': duration.inSeconds,
      'date': date.toIso8601String(),
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      subject: map['subject'] ?? '',
      duration: Duration(seconds: map['duration'] ?? 0),
      date: DateTime.parse(map['date']),
    );
  }

  String toJson() => json.encode(toMap());

  factory StudySession.fromJson(String source) =>
      StudySession.fromMap(json.decode(source));
}
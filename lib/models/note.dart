class Note {
  final String id;
  final String title;
  final String content;
  final String? subject; // null = sem matéria
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.subject,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'subject': subject,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      subject: map['subject'] as String?,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
// lib/fitness_app/my_diary/models/video.dart

class Video {
  final int id;
  final String title;
  final String status;
  final String source;
  final String info;
  final bool completed;

  Video({
    required this.id,
    required this.title,
    required this.status,
    required this.source,
    required this.info,
    required this.completed,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      source: json['source'],
      info: json['info'],
      completed: json['completed'] == 1,
    );
  }
}
import '../../../projects/domain/entities/project_entity.dart';

enum DesignTaskStatus { pending, inProgress, completed }

enum DesignMediaType { image, pdf, video, technical }

enum DesignVideoQuality {
  p480('480', '480p'),
  p720('720', '720p'),
  p1080('1080', '1080p');

  final String apiValue;
  final String label;

  const DesignVideoQuality(this.apiValue, this.label);
}

class DesignUser {
  final String id;
  final String name;
  const DesignUser({required this.id, required this.name});

  factory DesignUser.fromJson(Map<String, dynamic> json) => DesignUser(
    id: '${json['id']}',
    name: '${json['name'] ?? json['email'] ?? ''}',
  );
}

class DesignTask {
  final String id;
  final String title;
  final DesignTaskStatus status;
  final DesignUser? assignee;
  const DesignTask({
    required this.id,
    required this.title,
    required this.status,
    this.assignee,
  });

  factory DesignTask.fromJson(Map<String, dynamic> json) => DesignTask(
    id: '${json['id']}',
    title: '${json['title'] ?? json['name'] ?? ''}',
    status: _taskStatus('${json['status'] ?? 'TODO'}'),
    assignee: json['assignee'] is Map<String, dynamic>
        ? DesignUser.fromJson(json['assignee'] as Map<String, dynamic>)
        : null,
  );
}

class DesignMedia {
  final String id;
  final String name;
  final DesignMediaType type;
  final String size;
  final String? previewUrl;
  final String? downloadUrl;
  const DesignMedia({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    this.previewUrl,
    this.downloadUrl,
  });

  factory DesignMedia.fromJson(Map<String, dynamic> json) {
    final mime = '${json['mimeType'] ?? ''}'.toLowerCase();
    final url = json['url'] as String?;
    return DesignMedia(
      id: '${json['id']}',
      name: '${json['originalName'] ?? json['name'] ?? json['fileName'] ?? ''}',
      type: _mediaType(
        mime,
        '${json['originalName'] ?? json['fileName'] ?? ''}',
      ),
      size: _fileSize(json['size']),
      previewUrl: mime.startsWith('image/') ? url : null,
      downloadUrl: url,
    );
  }
}

class DesignActivity {
  final String id;
  final String author;
  final String type;
  final String message;
  final DateTime createdAt;
  final DesignMedia? media;
  const DesignActivity({
    required this.id,
    required this.author,
    required this.type,
    required this.message,
    required this.createdAt,
    this.media,
  });

  factory DesignActivity.fromJson(Map<String, dynamic> json) => DesignActivity(
    id: '${json['id']}',
    author: _authorName(json['author']),
    type: '${json['type'] ?? 'UPDATE'}',
    message: '${json['message'] ?? ''}',
    createdAt: DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(),
    media: json['attachment'] is Map<String, dynamic>
        ? DesignMedia.fromJson(json['attachment'] as Map<String, dynamic>)
        : null,
  );
}

class DesignWorkspace {
  final double projectValue;
  final List<ProjectInstallment> installments;
  final List<DesignTask> tasks;
  final List<DesignActivity> activities;
  final List<DesignMedia> media;
  final List<DesignUser> designers;
  const DesignWorkspace({
    required this.projectValue,
    required this.installments,
    required this.tasks,
    required this.activities,
    required this.media,
    required this.designers,
  });

  factory DesignWorkspace.fromJson(Map<String, dynamic> json) {
    final project = json['project'] is Map<String, dynamic>
        ? json['project'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final tasks = _maps(json['tasks']).map(DesignTask.fromJson).toList();
    final designers = _maps(
      json['designers'],
    ).map(DesignUser.fromJson).toList();
    for (final task in tasks) {
      final assignee = task.assignee;
      if (assignee != null &&
          !designers.any((user) => user.id == assignee.id)) {
        designers.add(assignee);
      }
    }
    return DesignWorkspace(
      projectValue: _double(project['projectValue']),
      installments: _maps(project['paymentSchedule'])
          .map(
            (item) => ProjectInstallment(
              id: '${item['id']}',
              amount: _double(item['amount']),
              dueDate:
                  DateTime.tryParse('${item['dueDate']}') ?? DateTime.now(),
              isPaid: item['isPaid'] as bool? ?? false,
              captures: _maps(item['captures'])
                  .map(
                    (capture) => ProjectInstallmentCapture(
                      id: '${capture['id']}',
                      url: '${capture['url'] ?? ''}',
                      fileName:
                          '${capture['fileName'] ?? capture['originalName'] ?? ''}',
                      mimeType: capture['mimeType'] as String?,
                      createdAt: DateTime.tryParse('${capture['createdAt']}'),
                    ),
                  )
                  .where((capture) => capture.url.isNotEmpty)
                  .toList(),
            ),
          )
          .toList(),
      tasks: tasks,
      activities: _maps(
        json['activities'] ?? json['timeline'],
      ).map(DesignActivity.fromJson).toList(),
      media: _maps(
        json['attachments'] ?? json['media'],
      ).map(DesignMedia.fromJson).toList(),
      designers: designers,
    );
  }

  double get totalReceived => installments
      .where((installment) => installment.isPaid)
      .fold(0, (sum, installment) => sum + installment.amount);
}

List<Map<String, dynamic>> _maps(dynamic value) =>
    value is List ? value.whereType<Map<String, dynamic>>().toList() : const [];
String _authorName(dynamic value) => value is Map<String, dynamic>
    ? '${value['name'] ?? value['email'] ?? ''}'
    : '${value ?? ''}';
DesignTaskStatus _taskStatus(String value) => switch (value.toUpperCase()) {
  'DONE' || 'COMPLETED' => DesignTaskStatus.completed,
  'IN_PROGRESS' => DesignTaskStatus.inProgress,
  _ => DesignTaskStatus.pending,
};
DesignMediaType _mediaType(String mime, String name) {
  if (mime.startsWith('image/')) {
    return DesignMediaType.image;
  }
  if (mime == 'application/pdf' || name.toLowerCase().endsWith('.pdf')) {
    return DesignMediaType.pdf;
  }
  if (mime.startsWith('video/')) {
    return DesignMediaType.video;
  }
  return DesignMediaType.technical;
}

String _fileSize(dynamic value) {
  final bytes = value is num
      ? value.toDouble()
      : double.tryParse('$value') ?? 0;
  if (bytes >= 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '${bytes.toStringAsFixed(0)} B';
}

double _double(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
